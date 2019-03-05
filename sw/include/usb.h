#ifndef __USB_H
#define __USB_H

#ifdef __cplusplus
extern "C" {
#endif

void usb_isr(void);
void usb_init(void);

#ifdef __cplusplus
}
#endif

#endif