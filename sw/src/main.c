#include <stdio.h>
#include <irq.h>
#include <uart.h>
#include <usb.h>
#include <time.h>
#include <dfu.h>
#include <rgb.h>
#include <spi.h>
#include <generated/csr.h>

struct ff_spi *spi;

void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();
}

#define REBOOT_ADDR 0x20040000
void reboot(void) {
    irq_setie(0);
    irq_setmask(0);
    usb_disconnect();
    spiFree();
    rgb_mode_error();

    // Check the first few words for the sync pulse;
    int i;
    int riscv_boot = 1;
    uint32_t *destination_array = (uint32_t *)REBOOT_ADDR;
    reboot_addr_write(REBOOT_ADDR);
    for (i = 0; i < 32; i++) {
        if ((destination_array[i] == 0x7e99aa7e)
         || (destination_array[i] == 0x7eaa997e)) {
            riscv_boot = 0;
            break;
        }
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

            // /* Flush the caches */
            // ".word 0x400f\n\t"
            // "nop\n\t"
            // "nop\n\t"
            // "nop\n\t"

            "ret\n\t"

            :
            : "r"(REBOOT_ADDR)
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
    dfu_init();
    time_init();
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
