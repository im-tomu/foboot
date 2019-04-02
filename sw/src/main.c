#include <stdio.h>
#include <irq.h>
#include <printf.h>
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

#ifdef CSR_UART_BASE
    if (irqs & (1 << UART_INTERRUPT))
        uart_isr();
#endif
}

#ifdef CSR_UART_BASE
static void rv_putchar(void *ignored, char c)
{
    (void)ignored;
    if (c == '\n')
        uart_write('\r');
    if (c == '\r')
        return;
    uart_write(c);
}
#endif

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

#if 0
static const char *usb_hw_api(void) {
#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR
    return "epfifo";
#else
#ifdef CSR_USB_OBUF_EMPTY_ADDR
    return "rawfifo";
#else
#ifdef CSR_USB_WHATEVER
    return "whatever";
#else
    return "unrecognized hw api";
#endif /* CSR_USB_WHATEVER */
#endif /* CSR_USB_OBUF_EMPTY_ADDR */
#endif /* CSR_USB_EP_0_OUT_EV_PENDING_ADDR */
}
#endif

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();

    usb_connect();
    while (1)
    {
        usb_poll(NULL);

    //     if (i > 200)
            // reboot_ctrl_write(0xac);
    }
    return 0;
}