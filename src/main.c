#include <stdio.h>
#include <irq.h>
#include <printf.h>
#include <uart.h>
#include <usb.h>
#include <time.h>

#include <generated/csr.h>

enum usb_responses {
    USB_STALL = 0b11,
    USB_ACK   = 0b00,
    USB_NAK   = 0b01,
    USB_NONE  = 0b10,
};

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
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    usb_init();
    time_init();
    init_printf(NULL, rv_putchar);
}

static uint32_t read_timer(void)
{
    timer0_update_value_write(1);
    return timer0_value_read();
}

#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR
struct usb_status
{
    // uint32_t out_ev_status;
    uint32_t out_ev_pending;
    uint32_t in_ev_status;
    uint32_t out_last_tok;
    uint32_t out_obuf_empty;
    uint32_t in_ibuf_empty;
};

static struct usb_status get_status(void)
{
    struct usb_status s;
    // s.out_ev_status = usb_ep_0_out_ev_status_read();
    s.out_ev_pending = usb_ep_0_out_ev_pending_read();
    s.in_ev_status = usb_ep_0_in_ev_status_read();
    s.out_last_tok = usb_ep_0_out_last_tok_read();
    s.out_obuf_empty = usb_ep_0_out_obuf_empty_read();
    s.in_ibuf_empty = usb_ep_0_in_ibuf_empty_read();
    return s;
}

static void get_print_status(void)
{
    static int loops;
    int obufbuf_cnt = 0;
    struct usb_status s = get_status();

    // printf("i: %8d  OEP: %02x  OBE: %02x  OLT: %02x\n",
    //         loops++,
    //         s.out_ev_pending,
    //         s.out_obuf_empty,
    //         s.out_last_tok);

    if (s.out_ev_pending & (1 << 1)) {
        loops++;
        uint8_t obufbuf[128];
        while (!usb_ep_0_out_obuf_empty_read()) {
            uint32_t obh = usb_ep_0_out_obuf_head_read();
            obufbuf[obufbuf_cnt++] = obh;
            usb_ep_0_out_obuf_head_write(1);
        }

        int i;
        printf("i: %d  b: %d olt: %02x  --", loops, obufbuf_cnt, s.out_last_tok);//obe: %d  obh: %02x\n", i, obe, obh);
        for (i = 0; i < obufbuf_cnt; i++) {
            printf(" %02x", obufbuf[i]);
        }
        printf("\n");

        usb_ep_0_out_ev_pending_write((1 << 1));

        // Response
        if (!usb_ep_0_in_ibuf_empty_read()) {
            printf("USB ibuf still has data\n");
            return;
        }

        uint32_t usb_in_pending = usb_ep_0_out_ev_pending_read();
        if (usb_in_pending) {
            printf("USB EP0 in pending is: %02x\n", usb_in_pending);
            return;
        }

        for (i = 0; i < 0x20; i++) {
            usb_ep_0_in_ibuf_head_write(i);
        }
        // Indicate that we respond with an ACK
        usb_ep_0_in_respond_write(USB_ACK);
        usb_ep_0_in_ev_pending_write(0xff);
    }
}
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
    printf("\nStatus: %d\n", usb_ep_0_out_ev_pending_read());
    get_print_status();
    usb_pullup_out_write(1);
    usb_ep_0_out_ev_pending_write((1 << 1));
    printf("Status: %d\n", usb_ep_0_out_obuf_empty_read());
    get_print_status();

    int i = 0;
    printf("Hello, world!\n");

    int last_event = 0;
    while (1)
    {
        // unsigned int timer_val_ok = read_timer();
        // int elapsed(int *last_event, int period)
        elapsed(&last_event, 1000);

        unsigned int timer_val_cur;
        // timer_val_cur = read_timer();
        // printf("10 PRINT HELLO, WORLD\n");
        // printf("20 GOTO 10\n");
        // printf("i: %d\n", i++);
        // timer_val_cur = read_timer();
        get_print_status();
        // while (timer0_value_read() != timer_val_ok) {
        // ;
        // }
    }
    return 0;
}