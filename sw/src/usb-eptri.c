#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <usb.h>
#include <usb-desc.h>

#ifdef CSR_USB_SETUP_STATUS_ADDR

__attribute__((aligned(4)))
static uint8_t volatile setup_packet[10];
volatile uint32_t setup_length;

__attribute__((used, aligned(4)))
static uint8_t volatile previous_setup_packet[10];
__attribute__((used))
volatile uint32_t previous_setup_length;

static uint8_t volatile out_buffer_length;
static uint8_t volatile out_buffer[128];
static uint8_t volatile out_ep;
static uint8_t volatile out_have;
static const int max_byte_length = 64;

static const uint8_t * volatile current_data;
static volatile int current_length;
static volatile uint8_t current_epno;
static volatile int data_offset;
static volatile int data_to_send;
static int next_packet_is_empty;

__attribute__((used))
const uint8_t * last_data;
__attribute__((used))
int last_length;
__attribute__((used))
int last_epno;
__attribute__((used))
int last_data_offset;
__attribute__((used))
int last_data_to_send;
__attribute__((used))
int last_packet_was_empty;

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

void usb_idle(void) {
    irq_setmask(irq_getmask() & ~(1 << USB_INTERRUPT));
}

void usb_disconnect(void) {
    irq_setmask(irq_getmask() & ~(1 << USB_INTERRUPT));
    usb_pullup_out_write(0);
}

void usb_connect(void) {
    usb_setup_ev_pending_write(usb_setup_ev_pending_read());
    usb_in_ev_pending_write(usb_in_ev_pending_read());
    usb_out_ev_pending_write(usb_out_ev_pending_read());
    usb_setup_ev_enable_write(1);
    usb_in_ev_enable_write(1);
    usb_out_ev_enable_write(1);

    // Accept incoming data by default.
    usb_out_ctrl_write(2);

    // Turn on the external pullup
    usb_pullup_out_write(1);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

void usb_init(void) {
    out_buffer_length = 0;
    usb_pullup_out_write(0);
    usb_address_write(0);
    usb_out_ctrl_write(0);

    usb_setup_ev_enable_write(0);
    usb_in_ev_enable_write(0);
    usb_out_ev_enable_write(0);

    // Reset the IN handler
    usb_in_ctrl_write(0x20);

    // Reset the SETUP handler
    usb_setup_ctrl_write(0x04);

    // Reset the OUT handler
    usb_out_ctrl_write(0x04);

    return;
}

static void process_tx(void) {

    // Don't allow requeueing -- only queue more data if the system is idle.
    if (!(usb_in_status_read() & 2)) {
        return;
    }

    // Don't send empty data
    if (!current_data || !current_length) {
        return;
    }

    last_data_offset = data_offset;
    data_offset += data_to_send;

    last_data_to_send = data_to_send;
    data_to_send = current_length - data_offset;

    // Clamp the data to the maximum packet length
    if (data_to_send > max_byte_length) {
        last_data_to_send = data_to_send;
        data_to_send = max_byte_length;
        last_packet_was_empty = next_packet_is_empty;
        next_packet_is_empty = 0;
    }
    else if (data_to_send == max_byte_length) {
        last_packet_was_empty = next_packet_is_empty;
        next_packet_is_empty = 1;
    }
    else if (next_packet_is_empty) {
        last_packet_was_empty = next_packet_is_empty;
        next_packet_is_empty = 0;

        last_data_to_send = data_to_send;
        data_to_send = 0;
    }
    else if (current_data == NULL || data_to_send <= 0) {
        last_packet_was_empty = next_packet_is_empty;
        next_packet_is_empty = 0;

        last_data = current_data;
        last_length = current_length;
        last_data_offset = data_offset;
        last_data_to_send = data_to_send;

        current_data = NULL;
        current_length = 0;
        data_offset = 0;
        data_to_send = 0;
        return;
    }

    int this_offset;
    for (this_offset = data_offset; this_offset < (data_offset + data_to_send); this_offset++) {
        usb_in_data_write(current_data[this_offset]);
    }

    // Updating the epno queues the data
    usb_in_ctrl_write(current_epno & 0xf);
    return;
}

static void process_rx(void) {
    // If we already have data in our buffer, don't do anything.
    if (out_have)
        return;

    // If there isn't any data in the FIFO, don't do anything.
    if (!(usb_out_status_read() & 1))
        return;

    out_have = 1;
    out_ep = (usb_out_status_read() >> 2) & 0xf;
    out_buffer_length = 0;
    while (usb_out_status_read() & 1) {
        out_buffer[out_buffer_length++] = usb_out_data_read();
        usb_out_ctrl_write(1);
    }
}

void usb_send(uint8_t epno, const void *data, int total_count) {
    while ((current_length || current_data) && !(usb_in_status_read() & 2))
        process_tx();
    last_epno = current_epno;

    current_data = (uint8_t *)data;
    current_length = total_count;
    current_epno = epno;
    data_offset = 0;
    data_to_send = 0;
    process_tx();
}

void usb_wait_for_send_done(void) {
    while (current_data && current_length)
        usb_poll();
    while ((usb_in_status_read() & 1) == 1)
        usb_poll();
}

uint32_t setup_packet_count = 0;
void usb_isr(void) {
    uint8_t setup_pending   = usb_setup_ev_pending_read();
    uint8_t in_pending      = usb_in_ev_pending_read();
    uint8_t out_pending     = usb_out_ev_pending_read();
    usb_setup_ev_pending_write(setup_pending);
    usb_in_ev_pending_write(in_pending);
    usb_out_ev_pending_write(out_pending);

    // We got a SETUP packet.  Copy it to the setup buffer and clear
    // the "pending" bit.
    if (setup_pending) {
        if (!(usb_setup_status_read() & 1))
            rgb_mode_error();
        previous_setup_length = setup_length;
        memcpy(previous_setup_packet, setup_packet, sizeof(setup_packet));

        setup_length = 0;
        memset(setup_packet, 0, sizeof(setup_packet));
        while (usb_setup_status_read() & 1) {
            setup_packet[setup_length++] = usb_setup_data_read();
            usb_setup_ctrl_write(1);
        }

        // If we have 8 bytes, that's a full SETUP packet.
        // Otherwise, it was an RX error.
        if (setup_length == 10) {
            setup_packet_count++;
        }
        else {
            rgb_mode_error();
            setup_length = 0;
        }
    }

    // An "IN" transaction just completed.
    if (in_pending) {
        // Process more data to send, if we have any.
        process_tx();
    } 

    // An "OUT" transaction just completed so we have new data.
    // (But only if we can accept the data)
    if (out_pending) {
        // out_buffer_length -= 2; // Strip CRC16
        process_rx();
    }
    return;
}

void usb_ack_in(void) {
    // while (usb_in_status_read() & 1)
    //     ;
    // usb_in_ctrl_write(0);
}

void usb_ack_out(void) {
    // while (usb_out_status_read() & 1)
    //     ;
    out_have = 0;
    usb_out_ctrl_write(2);
}

void usb_err(uint8_t ep) {
    if (ep)
        usb_in_ctrl_write(0x20);
    else
        usb_out_stall_write(0x10);
}

int usb_recv(void *buffer, unsigned int buffer_len) {
    usb_setup_ctrl_write(2); // Acknowledge we've handled the SETUP packet
    // Set the OUT response to ACK, since we are in a position to receive data now.
    if (out_have) {
        usb_ack_out();
    }
    while (1) {
        if (out_buffer_length) {
            if (buffer_len > out_buffer_length)
                buffer_len = out_buffer_length;
            memcpy(buffer, out_buffer, buffer_len);
            usb_ack_out();
            return buffer_len;
        }
    }
    return 0;
}

void usb_set_address(uint8_t new_address) {
    usb_address_write(new_address);
}

void usb_poll(void) {
    // If some data was received, then process it.
    if (setup_length) {
        setup_length = 0;
        usb_setup(setup_packet);
        if (setup_length == 0)
            usb_setup_ctrl_write(2); // Acknowledge we've handled the SETUP packet
    }

    if (out_have) {
        out_have = 0;
        if (out_ep > 0) {
            int i;
            for (i = 0; i < out_buffer_length; i++)
                out_buffer[i] += 1;
            usb_send(out_ep, out_buffer, out_buffer_length - 2);
        }
        usb_ack_out();
    }

    process_tx();
    process_rx();
}

// struct usb_status {
//     volatile uint32_t error_count;
//     volatile uint32_t tok_waits;
//     volatile uint32_t status;
//     volatile uint32_t address;
//     volatile uint32_t stage;
// };

// __attribute__((noinline))
// struct usb_status usb_get_status(void) {
//     struct usb_status usb_status;
//     usb_status.error_count = usb_error_count_read();
//     usb_status.tok_waits = usb_tok_waits_read();
//     usb_status.status = usb_status_read();
//     usb_status.address = usb_address_read();
//     usb_status.stage = usb_stage_num_read();
//     return usb_status;
// }

#else
#error "Not enabled"
#endif /* CSR_USB_SETUP_STATUS_ADDR */