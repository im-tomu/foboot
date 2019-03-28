#ifndef __USB_H
#define __USB_H

#ifdef __cplusplus
extern "C" {
#endif

struct usb_device;
struct usb_setup_request;

void usb_isr(void);
void usb_init(void);
void usb_connect(void);
void usb_disconnect(void);

int usb_irq_happened(void);
void usb_setup(struct usb_device *dev, const struct usb_setup_request *setup);
int usb_send(struct usb_device *dev, int epnum, const void *data, int total_count);
int usb_ack(struct usb_device *dev, int epnum);
int usb_err(struct usb_device *dev, int epnum);
int usb_recv(struct usb_device *dev, void *buffer, unsigned int buffer_len);
void usb_poll(struct usb_device *dev);
int usb_wait_for_send_done(struct usb_device *dev);

#ifdef __cplusplus
}
#endif

#endif