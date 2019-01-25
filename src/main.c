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

#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR
#else
static void get_print_status(void)
{
    static int loops;
    uint32_t obe = usb_obuf_empty_read();
    uint8_t obufbuf[128];
    int obufbuf_cnt = 0;
    loops++;

    while (!usb_obuf_empty_read()) {
        uint32_t obh = usb_obuf_head_read();
        obufbuf[obufbuf_cnt++] = obh;
        usb_obuf_head_write(1);
    }
    if (obufbuf_cnt) {
        int i;
        printf("i: %d  b: %d  --", loops, obufbuf_cnt);//obe: %d  obh: %02x\n", i, obe, obh);
        for (i = 0; i < obufbuf_cnt; i++) {
            printf(" %02x", obufbuf[i]);
        }
        printf("\n");
    }
    // if (!obe) {
    //     uint32_t obh = usb_obuf_head_read();
    //     usb_obuf_head_write(1);
    //     if (i < 300)
    //         printf("i: %8d  obe: %d  obh: %02x\n", i, obe, obh);
    // }
}
#endif

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();
    usb_pullup_out_write(1);
    usb_ep_0_out_ev_pending_write((1 << 1));
    if (usb_ep_0_out_ev_pending_read() & (1 << 1))
        usb_isr();

    printf("Hello, world!\n");

    while (1)
    {
        if (usb_ep_0_out_ev_pending_read() & (1 << 1))
            usb_isr();
        // elapsed(&last_event, 1000);

        // get_print_status();
    }
    return 0;
}