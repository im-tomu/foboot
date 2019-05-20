#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <usb.h>
#include <usb-msc.h>

#define EP0OUT_BUFFERS 4
#define EP2OUT_BUFFERS 4
__attribute__((aligned(4)))
static uint8_t volatile usb_ep0out_buffer_len[EP0OUT_BUFFERS];
static uint8_t volatile usb_ep0out_buffer[EP0OUT_BUFFERS][256];
static uint8_t volatile usb_ep0out_last_tok[EP0OUT_BUFFERS];
static volatile uint8_t usb_ep0out_wr_ptr;
static volatile uint8_t usb_ep0out_rd_ptr;

__attribute__((aligned(4)))
static uint8_t volatile usb_ep2out_buffer_len[EP2OUT_BUFFERS];
static uint8_t volatile usb_ep2out_buffer[EP2OUT_BUFFERS][256];
static volatile uint8_t usb_ep2out_wr_ptr;
static volatile uint8_t usb_ep2out_rd_ptr;

static const int max_byte_length = 64;

static const uint8_t * volatile current_data_0;
static volatile int current_length_0;
static volatile int data_offset_0;
static volatile int data_to_send_0;
static int next_packet_is_empty_0;

static const uint8_t * volatile current_data_2;
static volatile int current_length_2;
static volatile int data_offset_2;
static volatile int data_to_send_2;
static int next_packet_is_empty_2;

static void *ep2_more_data_ptr;
static volatile uint8_t ep2_more_data_bfr[64];
static int (*ep2_more_data)(uint8_t *bfr, size_t len, void *ptr);

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

static void process_tx(void);

void usb_idle(void) {
    usb_ep_0_out_ev_enable_write(0);
    usb_ep_0_in_ev_enable_write(0);

    // Reject all incoming data, since there is no handler anymore
    usb_ep_0_out_respond_write(EPF_NAK);

    // Reject outgoing data, since we don't have any to give.
    usb_ep_0_in_respond_write(EPF_NAK);

    irq_setmask(irq_getmask() & ~(1 << USB_INTERRUPT));
}

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

    usb_ep_2_out_ev_pending_write(usb_ep_2_out_ev_enable_read());
    usb_ep_2_in_ev_pending_write(usb_ep_2_in_ev_pending_read());
    usb_ep_2_out_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);
    usb_ep_2_in_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);

    // Accept incoming data by default.
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_2_out_respond_write(EPF_ACK);

    // Reject outgoing data, since we have none to give yet.
    usb_ep_0_in_respond_write(EPF_NAK);
    usb_ep_2_in_respond_write(EPF_NAK);
    usb_ep_2_in_dtb_write(1);

    usb_pullup_out_write(1);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

void usb_init(void) {
    usb_ep0out_wr_ptr = 0;
    usb_ep0out_rd_ptr = 0;
    usb_ep2out_wr_ptr = 0;
    usb_ep2out_wr_ptr = 0;
    usb_pullup_out_write(0);
    return;
}

void usb_isr(void) {
    uint8_t ep0o_pending = usb_ep_0_out_ev_pending_read();
    uint8_t ep0i_pending = usb_ep_0_in_ev_pending_read();
    uint8_t ep2o_pending = usb_ep_2_out_ev_pending_read();
    uint8_t ep2i_pending = usb_ep_2_in_ev_pending_read();

    // We got an OUT or a SETUP packet.  Copy it to usb_ep0out_buffer
    // and clear the "pending" bit.
    if (ep0o_pending) {
        uint8_t last_tok = usb_ep_0_out_last_tok_read();
        
        int byte_count = 0;
        usb_ep0out_last_tok[usb_ep0out_wr_ptr] = last_tok;
        volatile uint8_t * obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (!usb_ep_0_out_obuf_empty_read()) {
            obuf[byte_count++] = usb_ep_0_out_obuf_head_read();
            usb_ep_0_out_obuf_head_write(0);
        }

        /* Strip off CRC16 */
        if (byte_count >= 2)
            byte_count -= 2;
        usb_ep0out_buffer_len[usb_ep0out_wr_ptr] = byte_count;

        if (byte_count)
            usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);

        if (last_tok == USB_PID_SETUP) {
            usb_ep_0_in_dtb_write(1);
            data_offset_0 = 0;
            current_length_0 = 0;
            current_data_0 = NULL;
        }

        usb_ep_0_out_ev_pending_write(ep0o_pending);
        usb_ep_0_out_respond_write(EPF_ACK);
    }

    // We got an OUT or a SETUP packet.  Copy it to usb_ep0out_buffer
    // and clear the "pending" bit.
    if (ep2o_pending) {
        uint8_t byte_count = 0;
        volatile uint8_t * obuf = usb_ep2out_buffer[usb_ep2out_wr_ptr];
        while (!usb_ep_2_out_obuf_empty_read()) {
            obuf[byte_count++] = usb_ep_2_out_obuf_head_read();
            usb_ep_2_out_obuf_head_write(0);
        }

        /* Strip off CRC16 */
        if (byte_count >= 2)
            byte_count -= 2;
        usb_ep2out_buffer_len[usb_ep2out_wr_ptr] = byte_count;

        if (byte_count)
            usb_ep2out_wr_ptr = (usb_ep2out_wr_ptr + 1) & (EP2OUT_BUFFERS-1);

        usb_ep_2_out_ev_pending_write(ep2o_pending);
        usb_ep_2_out_respond_write(EPF_ACK);
    }

    // We just got an "IN" token.  Send data if we have it.
    if (ep0i_pending) {
        usb_ep_0_in_respond_write(EPF_NAK);
        usb_ep_0_in_ev_pending_write(ep0i_pending);
    }

    // We just got an "IN" token.  Send data if we have it.
    if (ep2i_pending) {
        usb_ep_2_in_respond_write(EPF_NAK);
        usb_ep_2_in_ev_pending_write(ep2i_pending);
        process_tx();
    }
}

static void process_tx_0(void) {

    // Don't allow requeueing -- only queue more data if we're
    // currently set up to respond NAK.
    if (usb_ep_0_in_respond_read() != EPF_NAK) {
        return;
    }

    // Prevent us from double-filling the buffer.
    if (!usb_ep_0_in_ibuf_empty_read()) {
        return;
    }

    if (!current_data_0 || !current_length_0) {
        return;
    }

    data_offset_0 += data_to_send_0;

    data_to_send_0 = current_length_0 - data_offset_0;

    // Clamp the data to the maximum packet length
    if (data_to_send_0 > max_byte_length) {
        data_to_send_0 = max_byte_length;
        next_packet_is_empty_0 = 0;
    }
    else if (data_to_send_0 == max_byte_length) {
        next_packet_is_empty_0 = 1;
    }
    else if (next_packet_is_empty_0) {
        next_packet_is_empty_0 = 0;
        data_to_send_0 = 0;
    }
    else if (current_data_0 == NULL || data_to_send_0 <= 0) {
        next_packet_is_empty_0 = 0;
        current_data_0 = NULL;
        current_length_0 = 0;
        data_offset_0 = 0;
        data_to_send_0 = 0;
        return;
    }

    int this_offset_0;
    for (this_offset_0 = data_offset_0; this_offset_0 < (data_offset_0 + data_to_send_0); this_offset_0++) {
        usb_ep_0_in_ibuf_head_write(current_data_0[this_offset_0]);
    }
    usb_ep_0_in_respond_write(EPF_ACK);
    return;
}

static void process_tx_2(void) {

    // Don't allow requeueing -- only queue more data if we're
    // currently set up to respond NAK.
    if (usb_ep_2_in_respond_read() != EPF_NAK) {
        return;
    }

    // Prevent us from double-filling the buffer.
    if (!usb_ep_2_in_ibuf_empty_read()) {
        return;
    }

    // If we have a callback, use that.
    if (ep2_more_data) {
        uint8_t data_bfr[64];
        int new_bytes = ep2_more_data(data_bfr, sizeof(data_bfr), ep2_more_data_ptr);
        if (new_bytes == 0) {
            usb_ep_2_in_respond_write(EPF_ACK);
            ep2_more_data_ptr = NULL;
            ep2_more_data = NULL;
        }
        else if (new_bytes == -1) {
            ep2_more_data_ptr = NULL;
            ep2_more_data = NULL;
        }
        else if (new_bytes < -1) {
            usb_ep_2_in_respond_write(EPF_STALL);
            ep2_more_data_ptr = NULL;
            ep2_more_data = NULL;
        }
        else {
            int off;
            for (off = 0; off < new_bytes; off++)
                usb_ep_2_in_ibuf_head_write(data_bfr[off]);
            usb_ep_2_in_respond_write(EPF_ACK);
        }
        return;
    }

    if (!current_data_2 || !current_length_2) {
        return;
    }

    data_offset_2 += data_to_send_2;

    data_to_send_2 = current_length_2 - data_offset_2;

    // Clamp the data to the maximum packet length
    if (data_to_send_2 > max_byte_length) {
        data_to_send_2 = max_byte_length;
        next_packet_is_empty_2 = 0;
    }
    else if (data_to_send_2 == max_byte_length) {
        next_packet_is_empty_2 = 1;
    }
    else if (next_packet_is_empty_2) {
        next_packet_is_empty_2 = 0;
        data_to_send_2 = 0;
    }
    else if (current_data_2 == NULL || data_to_send_2 <= 0) {
        next_packet_is_empty_2 = 0;
        current_data_2 = NULL;
        current_length_2 = 0;
        data_offset_2 = 0;
        data_to_send_2 = 0;
        return;
    }

    int this_offset_2;
    for (this_offset_2 = data_offset_2; this_offset_2 < (data_offset_2 + data_to_send_2); this_offset_2++) {
        usb_ep_2_in_ibuf_head_write(current_data_2[this_offset_2]);
    }
    usb_ep_2_in_respond_write(EPF_ACK);
    return;
}

static void process_tx(void) {
    process_tx_0();
    process_tx_2();
}

void usb_wait_for_send_done(void) {
    while (current_data_0 && current_length_0)
        usb_poll();
    while ((usb_ep_0_in_dtb_read() & 1) == 1)
        usb_poll();
}

void usb_ack(int epnum) {
    switch (epnum) {
    case 0x00:
        while (usb_ep_0_out_respond_read() == EPF_ACK)
            ;
        usb_ep_0_out_respond_write(EPF_ACK);
        break;

    case 0x80:
        while (usb_ep_0_in_respond_read() == EPF_ACK)
            ;
        usb_ep_0_in_respond_write(EPF_ACK);
        break;

    case 0x02:
        while (usb_ep_2_out_respond_read() == EPF_ACK)
            ;
        usb_ep_2_out_respond_write(EPF_ACK);
        break;

    case 0x82:
        while (usb_ep_2_in_respond_read() == EPF_ACK)
            ;
        usb_ep_2_in_respond_write(EPF_ACK);
        break;
    }
}

void usb_stall(int epnum) {
    switch (epnum) {
    case 0x00:
        usb_ep_0_out_respond_write(EPF_STALL);
        break;
    case 0x80:
        usb_ep_0_in_respond_write(EPF_STALL);
        break;
    case 0x02:
        usb_ep_2_out_respond_write(EPF_STALL);
        break;
    case 0x82:
        usb_ep_2_in_respond_write(EPF_STALL);
        break;
    }
}

void usb_send_cb(int epnum, int (*cb)(uint8_t *, size_t, void *), void *ptr) {
    if (epnum == 2) {
        ep2_more_data = cb;
        ep2_more_data_ptr = ptr;
        process_tx();
    }
}

void usb_send(int epnum, const void *data, size_t total_count) {
    switch (epnum) {
    case 0:
        while ((usb_ep_0_in_respond_read() == EPF_ACK) && (current_length_0 != 0) && (current_data_0 != 0))
            ;
        current_data_0 = (uint8_t *)data;
        current_length_0 = total_count;
        data_offset_0 = 0;
        data_to_send_0 = 0;
        if (!total_count)
            usb_ep_0_in_respond_write(EPF_ACK);
        break;

    case 2:
        while ((usb_ep_2_in_respond_read() == EPF_ACK) && (current_length_2 != 0) && (current_data_2 != 0))
            ;
        if (!total_count) {
            usb_ep_2_in_respond_write(EPF_ACK);
        }
        else {
            current_data_2 = (uint8_t *)data;
            current_length_2 = total_count;
            data_offset_2 = 0;
            data_to_send_2 = 0;
        }
        break;
    }
    process_tx();
}

int usb_recv(void *buffer, unsigned int buffer_len) {

    // Set the OUT response to ACK, since we are in a position to receive data now.
    usb_ep_0_out_respond_write(EPF_ACK);
    while (1) {
        if (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
            if (usb_ep0out_last_tok[usb_ep0out_rd_ptr] == USB_PID_OUT) {
                unsigned int ep0_buffer_len = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
                if (ep0_buffer_len < buffer_len)
                    buffer_len = ep0_buffer_len;
                // usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
                memcpy(buffer, (void *)&usb_ep0out_buffer[usb_ep0out_rd_ptr], buffer_len);
                usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
                return buffer_len;
            }
            usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
        }
    }
    return 0;
}

void usb_poll(void) {
    // If some data was received, then process it.
    while (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        const struct usb_setup_request *request = (const struct usb_setup_request *)(usb_ep0out_buffer[usb_ep0out_rd_ptr]);
        // uint8_t len = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
        uint8_t last_tok = usb_ep0out_last_tok[usb_ep0out_rd_ptr];

        // usb_ep0out_buffer_len[usb_ep0out_rd_ptr] = 0;
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);

        if (last_tok == USB_PID_SETUP) {
            usb_setup(request);
        }
    }

    while (usb_ep2out_rd_ptr != usb_ep2out_wr_ptr) {
        const uint8_t *data = (const void *)(usb_ep2out_buffer[usb_ep2out_rd_ptr]);
        uint8_t len = usb_ep2out_buffer_len[usb_ep2out_rd_ptr];

        // usb_send(2, data, len);
        usb_msc_out(data, len);

        usb_ep2out_buffer_len[usb_ep2out_rd_ptr] = 0;
        usb_ep2out_rd_ptr = (usb_ep2out_rd_ptr + 1) & (EP2OUT_BUFFERS-1);
    }

    process_tx();
}