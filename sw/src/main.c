#include <stdio.h>
#include <irq.h>
#include <uart.h>
#include <usb.h>
#include <time.h>
#include <dfu.h>
#include <rgb.h>
#include <spi.h>
#include <generated/csr.h>
#include <generated/mem.h>

struct ff_spi *spi;

// ICE40UP5K bitstream images (with SB_MULTIBOOT header) are
// 104250 bytes.  The SPI flash has 4096-byte erase blocks.
// The smallest divisible boundary is 4096*26.
#define FBM_OFFSET ((void *)(SPIFLASH_BASE + 0x1a000))

void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();
}

static void riscv_reboot_to(void *addr, uint32_t boot_config) {
    // If requested, just let USB be idle.  Otherwise, reset it.
    if (boot_config & 0x00000020) // NO_USB_RESET
        usb_idle();
    else
        usb_disconnect();

    // Figure out what mode to put SPI flash into.
    if (boot_config & 0x00000001) { // QPI_EN
        spiEnableQuad();
        picorvspi_cfg3_write(picorvspi_cfg3_read() | 0x20);
    }
    if (boot_config & 0x00000002) // DDR_EN
        picorvspi_cfg3_write(picorvspi_cfg3_read() | 0x40);
    if (boot_config & 0x00000002) // CFM_EN
        picorvspi_cfg3_write(picorvspi_cfg3_read() | 0x10);
    rgb_mode_error();

    // Vexriscv requires three extra nop cycles to flush the cache.
    if (boot_config & 0x00000010) { // FLUSH_CACHE
        asm("fence.i");
        asm("nop");
        asm("nop");
        asm("nop");
    }

    // Reset the Return Address, zero out some registers, and return.
    asm volatile(
        "mv ra,%0\n\t"    /* x1  */
        "mv sp,zero\n\t"  /* x2  */
        "mv gp,zero\n\t"  /* x3  */
        "mv tp,zero\n\t"  /* x4  */
        "mv t0,zero\n\t"  /* x5  */
        "mv t1,zero\n\t"  /* x6  */
        "mv t2,zero\n\t"  /* x7  */
        "mv x8,zero\n\t"  /* x8  */
        "mv s1,zero\n\t"  /* x9  */
        "mv a0,zero\n\t"  /* x10 */
        "mv a1,zero\n\t"  /* x11 */

        // /* Flush the caches */
        // ".word 0x400f\n\t"
        // "nop\n\t"
        // "nop\n\t"
        // "nop\n\t"

        "ret\n\t"

        :
        : "r"(addr)
    );
}

// If Foboot_Main exists on SPI flash, and if the bypass isn't active,
// jump to FBM.
static void maybe_boot_fbm(void) {
    unsigned int i;
    int matches = 0;
    // Write a sequence of 10 bits out TOUCH2, and check their value
    // on TOUCH0.  Every time it matches, increment a counter.
    // If the counter matches 10 times, then don't boot FBM.
    for (i = 0; i < 10; i++) {
        // Set pin 2 as output, and pin 0 as input, and see if it loops back.
        touch_oe_write((1 << 2) | (0 << 0));
        touch_o_write((i&1) << 2);
        if ((i&1) == (touch_i_read() & (1 << 0)))
            matches++;
    }
    if (matches == 10)
        return;

    // We've determined that we won't force entry into FBR.  Check to see
    // if the FBM signature exists on flash.
    uint32_t *fbr_addr = FBM_OFFSET;
    for (i = 0; i < 64; i++) {
        if (fbr_addr[i] == 0x032bd37d)
            riscv_reboot_to(FBM_OFFSET, 0);
    }
}

void reboot(void) {
    irq_setie(0);
    irq_setmask(0);

    uint32_t reboot_addr = dfu_origin_addr();
    uint32_t boot_config = 0;

    // Free the SPI controller, which returns it to memory-mapped mode.
    spiFree();

    // Scan for configuration data.
    int i;
    int riscv_boot = 1;
    uint32_t *destination_array = (uint32_t *)reboot_addr;
    for (i = 0; i < 32; i++) {
        // Look for FPGA sync pulse.
        if ((destination_array[i] == CONFIG_BITSTREAM_SYNC_HEADER1)
         || (destination_array[i] == CONFIG_BITSTREAM_SYNC_HEADER2)) {
            riscv_boot = 0;
            break;
        }
        // Look for "boot config" word
        else if (destination_array[i] == 0xb469075a) {
            boot_config = destination_array[i + 1];
        }
    }

    if (riscv_boot) {
        riscv_reboot_to((void *)reboot_addr, boot_config);
    }
    else {
        // Issue a reboot
        warmboot_to_image(2);
    }
    __builtin_unreachable();
}

static void init(void)
{
    rgb_init();
    spi = spiAlloc();
    spiSetPin(spi, SP_MOSI, 0);
    spiSetPin(spi, SP_MISO, 1);
    spiSetPin(spi, SP_WP, 2);
    spiSetPin(spi, SP_HOLD, 3);
    spiSetPin(spi, SP_CLK, 4);
    spiSetPin(spi, SP_CS, 5);
    spiSetPin(spi, SP_D0, 0);
    spiSetPin(spi, SP_D1, 1);
    spiSetPin(spi, SP_D2, 2);
    spiSetPin(spi, SP_D3, 3);
    spiInit(spi);
    spiFree();
    maybe_boot_fbm();

    spiInit(spi);
#ifdef CSR_UART_BASE
    init_printf(NULL, rv_putchar);
#endif
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    usb_init();
    dfu_init();
    time_init();

}

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();

    usb_connect();
    while (1)
    {
        usb_poll();
        dfu_poll();
    }
    return 0;
}
