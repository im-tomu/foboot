#include <grainuum.h>
#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <printf.h>
#include <uart.h>

#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR

/* The state machine states of a control pipe */
enum CONTROL_STATE
{
    WAIT_SETUP,
    IN_DATA,
    OUT_DATA,
    LAST_IN_DATA,
    WAIT_STATUS_IN,
    WAIT_STATUS_OUT,
    STALLED,
} control_state;

#define NUM_BUFFERS 4
#define BUFFER_SIZE 64
#define EP_INTERVAL_MS 6
static const char hex[] = "0123456789abcdef";

enum epfifo_response {
    EPF_ACK = 0,
    EPF_NAK = 1,
    EPF_NONE = 2,
    EPF_STALL = 3,
};

#define USB_EV_ERROR 1
#define USB_EV_PACKET 2

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
    return;
}

volatile int irq_count = 0;

#define EP0OUT_BUFFERS 4
__attribute__((aligned(4)))
static uint8_t usb_ep0out_buffer[EP0OUT_BUFFERS][128];
static uint8_t usb_ep0out_buffer_len[EP0OUT_BUFFERS];
static uint8_t usb_ep0out_last_tok[EP0OUT_BUFFERS];
uint8_t usb_ep0out_wr_ptr;
uint8_t usb_ep0out_rd_ptr;
int max_byte_length = 64;

static const uint8_t *current_data;
static int current_length;
static int current_offset;
static int current_to_send;

static int queue_more_data(int epnum) {
    (void)epnum;
    // Don't allow requeueing
    if (usb_ep_0_in_respond_read() != EPF_NAK)
        return -1;

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
    // Don't allow requeueing
    // if (usb_ep_0_in_respond_read() != EPF_NAK)
        // return -1;
    if (!usb_ep_0_in_ibuf_empty_read()) {
        printf("IBUF isn't empty.  Error? %d\n", usb_usb_transfer_error_state_read());
        return -1;
    }
/*
    while (!usb_ep_0_in_ibuf_empty_read()) {
        printf("Emptying out ibuf...\n");
        usb_ep_0_in_ibuf_head_read();
    }
    */
    current_data = (uint8_t *)data;
    current_length = total_count;
    current_offset = 0;
    control_state = IN_DATA;
    queue_more_data(epnum);
    return 0;
}

void usb_isr(void) {
#if 0
    uint8_t ep0o_pending = usb_ep_0_out_ev_pending_read();
    uint8_t ep0i_pending = usb_ep_0_in_ev_pending_read();
    while (!usb_ep_0_out_obuf_empty_read()) {
        usb_ep_0_out_obuf_head_write(0);
    }
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_0_in_respond_write(EPF_ACK);
    usb_ep_0_out_ev_pending_write(ep0o_pending);
    usb_ep_0_in_ev_pending_write(ep0i_pending);
#else
    irq_count++;
    uint8_t ep0o_pending = usb_ep_0_out_ev_pending_read();
    uint8_t ep0i_pending = usb_ep_0_in_ev_pending_read();
    printf(">> %02x %02x <<\n", ep0o_pending, ep0i_pending);

    // We got an OUT or a SETUP packet.  Copy it to usb_ep0out_buffer
    // and clear the "pending" bit.
    if (ep0o_pending) {
        
        int byte_count = 0;
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (!usb_ep_0_out_obuf_empty_read()) {
            obuf[byte_count++] = usb_ep_0_out_obuf_head_read();
            usb_ep_0_out_obuf_head_write(0);
        }
        usb_ep_0_out_ev_pending_write(ep0o_pending);

        if (byte_count) {
            printf("read %d bytes: [", byte_count);
            unsigned int i;
            for (i = 0; i < byte_count; i++) {
                uart_write(' ');
                uart_write(hex[(obuf[i] >> 4) & 0xf]);
                uart_write(hex[obuf[i] & (0xf)]);
            }
            uart_write(' ]');
            uart_write('\r');
            uart_write('\n');
            usb_ep0out_buffer_len[usb_ep0out_wr_ptr] = byte_count;
            usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);
        }
        else {
            printf("read no bytes\n");
            usb_ep_0_out_respond_write(EPF_ACK);
        }
    }

    // We just got an "IN" token.  Send data if we have it.
    if (ep0i_pending) {
        usb_ep_0_in_respond_write(EPF_NAK);
        current_offset += current_to_send;
        queue_more_data(0);
        usb_ep_0_in_ev_pending_write(ep0i_pending);

        // Get ready to respond with an empty data byte
        if (current_offset >= current_length) {
            current_offset = 0;
            current_length = 0;
            current_data = NULL;
            if (control_state == IN_DATA) {
                usb_ep_0_out_respond_write(EPF_ACK);
            }
        }
        else
            usb_ep_0_in_respond_write(EPF_NAK);
    }
#endif
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
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_0_in_respond_write(EPF_ACK);
}

int usb_err(struct usb_device *dev, int epnum) {
    printf("STALLING!!!\n");
    usb_ep_0_out_respond_write(EPF_STALL);
    usb_ep_0_in_respond_write(EPF_STALL);
}

int usb_recv(struct usb_device *dev, void *buffer, unsigned int buffer_len) {
    return;
}


void usb_poll(void) {
    static int last_error_count;
    int this_error_count = usb_usb_transfer_error_state_read();
    if (last_error_count != this_error_count) {
        printf("USB TRANSFER ERROR STATE # %d!! WaitHand? %d  WaitData? %d  PID: %02x (was: %02x, full: %02x)\n", this_error_count, usb_dbg_lwh_read(), usb_dbg_lwd_read(), usb_usb_transfer_o_pid_read(), usb_usb_transfer_error_pid_read(), usb_dbg_lfp_read());
        last_error_count = this_error_count;
    }
    // If some data was received, then process it.
    if (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        const struct usb_setup_request *request = (const struct usb_setup_request *)(usb_ep0out_buffer[usb_ep0out_rd_ptr]);
        
        usb_setup(NULL, request);
        usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
    }

    if ((usb_ep_0_in_respond_read() == EPF_NAK) && (current_data))
        queue_more_data(0);

    // Cancel any pending transfers
    if ((control_state == IN_DATA) && usb_ep_0_in_ibuf_empty_read()) {
        printf("state is IN_DATA but ibuf is empty?\n");
        usb_ack(NULL, 0);
        printf("and obuf_empty_read(): %d\n", usb_ep_0_out_obuf_empty_read());
        usb_ep_0_out_obuf_head_write(0);
        control_state = WAIT_SETUP;
    }
    // if (!usb_ep_0_out_obuf_empty_read()) {
    //     printf("FATAL: obuf not empty, and pending is %d\n", usb_ep_0_out_ev_pending_read());
    //     printf("HALT");
    //     while (1)
    //         ;
    // }
    // if (!usb_ep_0_in_ibuf_empty_read()) {
        // usb_ep_0_in_ibuf_head_write(0);
    // }
    // usb_ack(NULL, 0);
}

void usb_print_status(void) {
    while (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        // printf("current_data: 0x%08x\n", current_data);
        // printf("current_length: %d\n", current_length);
        // printf("current_offset: %d\n", current_offset);
        // printf("current_to_send: %d\n", current_to_send);
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_rd_ptr];
        uint8_t cnt = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
        unsigned int i;
        if (cnt) {
            for (i = 0; i < cnt; i++) {
                uart_write(' ');
                uart_write(hex[(obuf[i+1] >> 4) & 0xf]);
                uart_write(hex[obuf[i+1] & (0xf)]);
            }
            uart_write('\r');
            uart_write('\n');
        }
        usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
    }
}

#endif /* CSR_USB_EP_0_OUT_EV_PENDING_ADDR */