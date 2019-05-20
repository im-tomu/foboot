#ifndef __USB_H
#define __USB_H

#include <stddef.h>
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
void usb_send(int epnum, const void *data, size_t total_count);
void usb_send_cb(int epnum, int (*cb)(uint8_t *, size_t, void *), void *ptr);
void usb_ack(int epnum);
void usb_stall(int epnum);
int usb_recv(void *buffer, size_t buffer_len);
void usb_poll(void);
void usb_wait_for_send_done(void);

#ifdef __cplusplus
}
#endif

#endif