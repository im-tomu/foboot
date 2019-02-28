#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <printf.h>
#include <uart.h>

#ifdef CSR_USB_OBUF_EMPTY_ADDR

static inline unsigned char usb_obuf_head_read(void);
static inline void usb_obuf_head_write(unsigned char value);

static inline unsigned char usb_obuf_empty_read(void);

static inline unsigned char usb_arm_read(void);
static inline void usb_arm_write(unsigned char value);

static inline unsigned char usb_ibuf_head_read(void);
static inline void usb_ibuf_head_write(unsigned char value);

static inline unsigned char usb_ibuf_empty_read(void);

static inline unsigned char usb_pullup_out_read(void);
static inline void usb_pullup_out_write(unsigned char value);

static inline unsigned char usb_ev_status_read(void);
static inline void usb_ev_status_write(unsigned char value);

static inline unsigned char usb_ev_pending_read(void);
static inline void usb_ev_pending_write(unsigned char value);

static inline unsigned char usb_ev_enable_read(void);
static inline void usb_ev_enable_write(unsigned char value);
    
static const char hex[] = "0123456789abcdef";

uint8_t usb_ep0out_wr_ptr;
uint8_t usb_ep0out_rd_ptr;
#define EP0OUT_BUFFERS 64
static uint8_t usb_ep0out_buffer[EP0OUT_BUFFERS][128];
void usb_print_status(void)
{
    static int loops;
    loops++;

    while (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_rd_ptr];
        uint8_t cnt = obuf[0];
        unsigned int i;
        if (cnt) {
            for (i = 0; i < cnt; i++) {
                uart_write(' ');
                uart_write(hex[(obuf[i+1] >> 4) & 0xf]);
                uart_write(hex[obuf[i+1] & (0xf)]);
                // printf(" %02x", obufbuf[i]);
            }
            uart_write('\r');
            uart_write('\n');
        }
        // printf("\n");
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
    }
    // if (!obe) {
    //     uint32_t obh = usb_obuf_head_read();
    //     usb_obuf_head_write(1);
    //     if (i < 300)
    //         printf("i: %8d  obe: %d  obh: %02x\n", i, obe, obh);
    // }
}

int irq_happened;

void usb_init(void) {
    return;
}

void usb_isr(void) {
    uint8_t pending = usb_ev_pending_read();

    // Advance the obuf head, which will reset the obuf_empty bit
    if (pending & 1) {
        int byte_count = 0;
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (1) {
            if (usb_obuf_empty_read())
                break;
            obuf[++byte_count] = usb_obuf_head_read();
            usb_obuf_head_write(0);
        }
        usb_ev_pending_write(1);
        obuf[0] = byte_count;
        usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);
    }

    return;
}

void usb_connect(void) {
    usb_pullup_out_write(1);

    usb_ev_pending_write(usb_ev_pending_read());
    usb_ev_enable_write(0xff);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

void usb_wait(void) {
    while (!irq_happened)
        ;
}

int usb_irq_happened(void) {
  return irq_happened;
}

#endif /* CSR_USB_OBUF_EMPTY_ADDR */