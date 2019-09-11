#ifndef __USB_H
#define __USB_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct usb_setup_request;

void usb_isr(void);
void usb_init(void);
void usb_connect(void);
void usb_idle(void);
void usb_disconnect(void);

int usb_irq_happened(void);
void usb_setup(const struct usb_setup_request *setup);
void usb_send(const void *data, int total_count);
void usb_ack_in(void);
void usb_ack_out(void);
void usb_err(uint8_t ep);
int usb_recv(void *buffer, unsigned int buffer_len);
void usb_poll(void);
void usb_wait_for_send_done(void);
void usb_set_address(uint8_t new_address);

#ifdef __cplusplus
}
#endif

#endif