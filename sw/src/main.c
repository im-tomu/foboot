#include <stdio.h>
#include <irq.h>
#include <printf.h>
#include <uart.h>
#include <usb.h>
#include <time.h>

#include <generated/csr.h>

void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();

    if (irqs & (1 << UART_INTERRUPT))
        uart_isr();
}

static void rv_putchar(void *ignored, char c)
{
    (void)ignored;
    if (c == '\n')
        uart_write('\r');
    if (c == '\r')
        return;
    uart_write(c);
}

static void init(void)
{
    init_printf(NULL, rv_putchar);
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    usb_init();
    time_init();
}

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

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();

    printf("\n\nUSB API: %s\n", usb_hw_api());
    // printf("Press any key to enable USB...\n");
 
    // usb_print_status();
    // uart_read();
    printf("Enabling USB\n");
    usb_connect();
    printf("USB enabled.\n");
    // usb_print_status();
    int last = 0;
    static uint8_t bfr[12];
    while (1)
    {
        if (usb_irq_happened() != last) {
            last = usb_irq_happened();
            printf("USB %d IRQ happened\n", last);
        }
        usb_poll();
        /*
        printf("Press any key to send...  ");
        uart_read();
        printf("Sending...  ");
        bfr[0] = 0;
        bfr[1] = ~0;
        bfr[2] = 0;
        usb_send(NULL, 0, bfr, 1);
        printf("Sent\n");
        */
    }
    return 0;
}