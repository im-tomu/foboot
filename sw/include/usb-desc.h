/* Teensyduino Core Library
 * http://www.pjrc.com/teensy/
 * Copyright (c) 2013 PJRC.COM, LLC.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 *
 * 2. If the Software is incorporated into a build system that allows 
 * selection among a list of target devices, then similar target
 * devices manufactured by PJRC.COM must be included in the list of
 * target devices and selectable in the same manner.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef _usb_desc_h_
#define _usb_desc_h_

#include <stdint.h>
#include <stddef.h>
#include <dfu.h>
#include <webusb-defs.h>

struct usb_setup_request {
    union {
        struct {
            uint8_t bmRequestType;
            uint8_t bRequest;
        };
        uint16_t wRequestAndType;
    };
    uint16_t wValue;
    uint16_t wIndex;
    uint16_t wLength;
};

struct usb_string_descriptor_struct {
    uint8_t bLength;
    uint8_t bDescriptorType;
    uint16_t wString[];
};

#define NUM_USB_BUFFERS           8
#define VENDOR_ID                 0x1209    // pid.codes
#define PRODUCT_ID                0x5bf0    // Assigned to Fomu project
#define DEVICE_VER                0x0101    // Bootloader version
#define MANUFACTURER_NAME         u"Foosn"
#define MANUFACTURER_NAME_LEN     sizeof(MANUFACTURER_NAME)
#define PRODUCT_NAME              u"Fomu DFU Bootloader " GIT_VERSION
#define PRODUCT_NAME_LEN          sizeof(PRODUCT_NAME)
#define EP0_SIZE                  64
#define NUM_INTERFACE             1

// Microsoft Compatible ID Feature Descriptor
#define MSFT_VENDOR_CODE    '~'     // Arbitrary, but should be printable ASCII
#define MSFT_WCID_LEN       40
extern const uint8_t usb_microsoft_wcid[MSFT_WCID_LEN];

typedef struct {
    uint16_t  wValue;
    uint16_t  length;
    const uint8_t *addr;
} usb_descriptor_list_t;

extern const usb_descriptor_list_t usb_descriptor_list[];

// WebUSB Landing page URL descriptor
#define WEBUSB_VENDOR_CODE 2

#ifndef LANDING_PAGE_URL
#define LANDING_PAGE_URL "dfu.fomu.im"
#endif

#define LANDING_PAGE_DESCRIPTOR_SIZE (WEBUSB_DT_URL_DESCRIPTOR_SIZE \
                                    + sizeof(LANDING_PAGE_URL) - 1)

const uint8_t *get_landing_url_descriptor(uint32_t *datalen);

/* USB Descriptor Types - Table 9-5 */
#define USB_DT_DEVICE				1
#define USB_DT_CONFIGURATION			2
#define USB_DT_STRING				3
#define USB_DT_INTERFACE			4
#define USB_DT_ENDPOINT				5
#define USB_DT_DEVICE_QUALIFIER			6
#define USB_DT_OTHER_SPEED_CONFIGURATION	7
#define USB_DT_INTERFACE_POWER			8
#define USB_DT_INTERFACE_SIZE			9
#define USB_DT_ENDPOINT_SIZE		7

/* USB bEndpointAddress helper macros */
#define USB_ENDPOINT_ADDR_OUT(x) (x)
#define USB_ENDPOINT_ADDR_IN(x) (0x80 | (x))

/* USB Endpoint Descriptor bmAttributes bit definitions - Table 9-13 */
/* bits 1..0 : transfer type */
#define USB_ENDPOINT_ATTR_CONTROL		0x00
#define USB_ENDPOINT_ATTR_ISOCHRONOUS		0x01
#define USB_ENDPOINT_ATTR_BULK			0x02
#define USB_ENDPOINT_ATTR_INTERRUPT		0x03
#define USB_ENDPOINT_ATTR_TYPE		0x03
/* bits 3..2 : Sync type (only if ISOCHRONOUS) */
#define USB_ENDPOINT_ATTR_NOSYNC		0x00
#define USB_ENDPOINT_ATTR_ASYNC			0x04
#define USB_ENDPOINT_ATTR_ADAPTIVE		0x08
#define USB_ENDPOINT_ATTR_SYNC			0x0C
#define USB_ENDPOINT_ATTR_SYNCTYPE		0x0C
/* bits 5..4 : usage type (only if ISOCHRONOUS) */
#define USB_ENDPOINT_ATTR_DATA			0x00
#define USB_ENDPOINT_ATTR_FEEDBACK		0x10
#define USB_ENDPOINT_ATTR_IMPLICIT_FEEDBACK_DATA 0x20
#define USB_ENDPOINT_ATTR_USAGETYPE		0x30

#endif
