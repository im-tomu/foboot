#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <printf.h>
#include <uart.h>
#include <usb.h>

#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR

/* The state machine states of a control pipe */
enum CONTROL_STATE
{
    WAIT_SETUP,
    IN_SETUP,
    IN_DATA,
    OUT_DATA,
    LAST_IN_DATA,
    WAIT_STATUS_IN,
    WAIT_STATUS_OUT,
    STALLED,
} control_state;

// Note that our PIDs are only bits 2 and 3 of the token,
// since all other bits are effectively redundant at this point.
enum USB_PID {
    USB_PID_OUT   = 0,
    USB_PID_SOF   = 1,
    USB_PID_IN    = 2,
    USB_PID_SETUP = 3,
};

enum epfifo_response {
    EPF_ACK = 0,
    EPF_NAK = 1,
    EPF_NONE = 2,
    EPF_STALL = 3,
};

#define USB_EV_ERROR 1
#define USB_EV_PACKET 2

void usb_disconnect(void) {
    usb_ep_0_out_ev_enable_write(0);
    usb_ep_0_in_ev_enable_write(0);
    irq_setmask(irq_getmask() & ~(1 << USB_INTERRUPT));
    usb_pullup_out_write(0);
}

void usb_connect(void) {

    usb_ep_0_out_ev_pending_write(usb_ep_0_out_ev_enable_read());
    usb_ep_0_in_ev_pending_write(usb_ep_0_in_ev_pending_read());
    usb_ep_0_out_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);
    usb_ep_0_in_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);

    // By default, it wants to respond with NAK.
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_0_in_respond_write(EPF_ACK);

    usb_pullup_out_write(1);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

void usb_init(void) {
    usb_pullup_out_write(0);
    return;
}

static volatile int irq_count = 0;

#define EP0OUT_BUFFERS 8
__attribute__((aligned(4)))
static uint8_t usb_ep0out_buffer[EP0OUT_BUFFERS][256];
static uint8_t usb_ep0out_buffer_len[EP0OUT_BUFFERS];
static uint8_t usb_ep0out_last_tok[EP0OUT_BUFFERS];
static volatile uint8_t usb_ep0out_wr_ptr;
static volatile uint8_t usb_ep0out_rd_ptr;
static const int max_byte_length = 64;

static const uint8_t *current_data;
static int current_length;
static int current_offset;
static int current_to_send;

static int queue_more_data(int epnum) {
    (void)epnum;

    // Don't allow requeueing -- only queue more data if we're
    // currently set up to respond NAK.
    if (usb_ep_0_in_respond_read() != EPF_NAK)
        return -1;

    // Prevent us from double-filling the buffer.
    if (!usb_ep_0_in_ibuf_empty_read()) {
        usb_ep_0_in_respond_write(EPF_ACK);
        return -1;
    }

    int this_offset;
    current_to_send = current_length - current_offset;
    if (current_to_send > max_byte_length)
        current_to_send = max_byte_length;

    for (this_offset = current_offset; this_offset < (current_offset + current_to_send); this_offset++) {
        usb_ep_0_in_ibuf_head_write(current_data[this_offset]);
    }
    usb_ep_0_in_respond_write(EPF_ACK);
    return 0;
}

int usb_send(struct usb_device *dev, int epnum, const void *data, int total_count) {
    (void)dev;

    while (current_data || current_length)
        ;
    current_data = (uint8_t *)data;
    current_length = total_count;
    current_offset = 0;
    control_state = IN_DATA;
    queue_more_data(epnum);

    return 0;
}

int usb_wait_for_send_done(struct usb_device *dev) {
    while (current_data && current_length)
        usb_poll(dev);
    while ((usb_ep_0_in_dtb_read() & 1) == 1)
        usb_poll(dev);
    return 0;
}

void usb_isr(void) {
    irq_count++;
    uint8_t ep0o_pending = usb_ep_0_out_ev_pending_read();
    uint8_t ep0i_pending = usb_ep_0_in_ev_pending_read();

    // We got an OUT or a SETUP packet.  Copy it to usb_ep0out_buffer
    // and clear the "pending" bit.
    if (ep0o_pending) {
        uint8_t last_tok = usb_ep_0_out_last_tok_read();
        
        int byte_count = 0;
        usb_ep0out_last_tok[usb_ep0out_wr_ptr] = last_tok;
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (!usb_ep_0_out_obuf_empty_read()) {
            obuf[byte_count++] = usb_ep_0_out_obuf_head_read();
            usb_ep_0_out_obuf_head_write(0);
        }
        usb_ep_0_out_ev_pending_write(ep0o_pending);
        usb_ep0out_buffer_len[usb_ep0out_wr_ptr] = byte_count - 2 /* Strip off CRC16 */;
        usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);

        if (last_tok == USB_PID_SETUP) {
            current_offset = 0;
            current_length = 0;
            current_data = NULL;
            control_state = IN_SETUP;
        }
    }

    // We just got an "IN" token.  Send data if we have it.
    if (ep0i_pending) {
        usb_ep_0_in_respond_write(EPF_NAK);
        current_offset += current_to_send;
        queue_more_data(0);
        usb_ep_0_in_ev_pending_write(ep0i_pending);
        usb_ep_0_out_respond_write(EPF_ACK);
    }
    
    return;
}

void usb_wait(void) {
    while (!irq_count)
        ;
}

int usb_irq_happened(void) {
    return irq_count;
}

int usb_ack(struct usb_device *dev, int epnum) {
    (void)dev;
    (void)epnum;
    usb_ep_0_in_dtb_write(1);
    usb_ep_0_out_dtb_write(1);
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_0_in_respond_write(EPF_ACK);
    return 0;
}

int usb_err(struct usb_device *dev, int epnum) {
    (void)dev;
    (void)epnum;
    usb_ep_0_out_respond_write(EPF_STALL);
    usb_ep_0_in_respond_write(EPF_STALL);
    return 0;
}

// int puts_noendl(const char *s);
// static void print_eptype(void) {
//     switch (usb_ep0out_last_tok[usb_ep0out_rd_ptr]) {
//     case 0: puts("O"); break;
//     // case 1: puts("SOF"); break;
//     // case 2: puts("IN"); break;
//     case 3: puts("S"); break;
//     }
// }

int usb_recv(struct usb_device *dev, void *buffer, unsigned int buffer_len) {
    (void)dev;

    // Set the OUT response to ACK, since we are in a position to receive data now.
    usb_ep_0_out_respond_write(EPF_ACK);
    while (1) {
        if (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
            if (usb_ep0out_last_tok[usb_ep0out_rd_ptr] == USB_PID_OUT) {
                unsigned int ep0_buffer_len = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
                if (ep0_buffer_len < buffer_len)
                    buffer_len = ep0_buffer_len;
                usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
                memcpy(buffer, &usb_ep0out_buffer[usb_ep0out_rd_ptr], buffer_len);
                usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
                return buffer_len;
            }
            usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
        }
    }
    return 0;
}

void usb_poll(struct usb_device *dev) {
    (void)dev;
    // If some data was received, then process it.
    if (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        const struct usb_setup_request *request = (const struct usb_setup_request *)(usb_ep0out_buffer[usb_ep0out_rd_ptr]);
        // unsigned int len = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
        uint8_t last_tok = usb_ep0out_last_tok[usb_ep0out_rd_ptr];

        usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);

        if (last_tok == USB_PID_SETUP) {
            usb_setup(NULL, request);
        }
    }

    if ((usb_ep_0_in_respond_read() == EPF_NAK) && (current_data)) {
        current_offset += current_to_send;
        queue_more_data(0);
    }
}

#endif /* CSR_USB_EP_0_OUT_EV_PENDING_ADDR */