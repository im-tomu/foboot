#include <stdio.h>
#include <irq.h>
#include <uart.h>
#include <usb.h>
#include <time.h>
#include <rgb.h>
#include <spi.h>
#include <generated/csr.h>

struct ff_spi *spi;

__attribute__((section(".ramtext")))
void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();
}

void reboot(void) {
    irq_setie(0);
    irq_setmask(0);

    uint32_t reboot_addr = 262144;
    uint32_t boot_config = 0;

    // Free the SPI controller, which returns it to memory-mapped mode.
    spiFree();

    // Scan for configuration data.
    int i;
    int riscv_boot = 1;
    uint32_t *destination_array = (uint32_t *)reboot_addr;
    reboot_addr_write(reboot_addr);
    for (i = 0; i < 32; i++) {
        // Look for FPGA sync pulse.
        if ((destination_array[i] == 0x7e99aa7e)
         || (destination_array[i] == 0x7eaa997e)) {
            riscv_boot = 0;
            break;
        }
        // Look for "boot config" word
        else if (destination_array[i] == 0xb469075a) {
            boot_config = destination_array[i + 1];
        }
    }

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

    if (riscv_boot) {
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
            "ret\n\t"

            :
            : "r"(reboot_addr)
        );
    }
    else {
        // Issue a reboot
        warmboot_to_image(2);
    }
    __builtin_unreachable();
}

static void init(void)
{
#ifdef CSR_UART_BASE
    init_printf(NULL, rv_putchar);
#endif
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    usb_init();
    time_init();
    rgb_init();
}

__attribute__((section(".ramtext")))
int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();

    usb_connect();
    while (1)
    {
        usb_poll();
    }
    return 0;
}
