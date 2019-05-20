#include <stdint.h>
#include <unistd.h>
#include <usb.h>
#include <system.h>

#include <usb-desc.h>
#include <usb-msc.h>

static uint8_t reply_buffer[8];
static uint8_t usb_configuration = 0;
#define USB_MAX_PACKET_SIZE 64
static uint32_t rx_buffer[USB_MAX_PACKET_SIZE/4];
uint16_t last_request_and_type;

__attribute__((section(".ramtext")))
void usb_setup(const struct usb_setup_request *setup)
{
    const uint8_t *data = NULL;
    uint32_t datalen = 0;
    const usb_descriptor_list_t *list;
    last_request_and_type = setup->wRequestAndType;

    switch (setup->wRequestAndType)
    {
    case 0xfea1: // Get Max LUN
        if (usb_msc_setup(setup))
            return;
        break;

    case 0x0500: // SET_ADDRESS
    case 0x0b01: // SET_INTERFACE
        break;

    case 0x0900: // SET_CONFIGURATION
        usb_configuration = setup->wValue;
        break;

    case 0x0880: // GET_CONFIGURATION
        reply_buffer[0] = usb_configuration;
        datalen = 1;
        data = reply_buffer;
        break;

    case 0x0080: // GET_STATUS (device)
        reply_buffer[0] = 0;
        reply_buffer[1] = 0;
        datalen = 2;
        data = reply_buffer;
        break;

    case 0x0082: // GET_STATUS (endpoint)
        if (setup->wIndex > 0)
        {
            usb_stall(0x80);
            return;
        }
        reply_buffer[0] = 0;
        reply_buffer[1] = 0;

        // XXX handle endpoint stall here
//        if (USB->DIEP0CTL & USB_DIEP_CTL_STALL)
//            reply_buffer[0] = 1;
        data = reply_buffer;
        datalen = 2;
        break;

    case 0x0102: // CLEAR_FEATURE (endpoint)
        if (setup->wIndex > 0 || setup->wValue != 0)
        {
            // TODO: do we need to handle IN vs OUT here?
            usb_stall(0x80);
            return;
        }
        // XXX: Should we clear the stall bit?
        // USB->DIEP0CTL &= ~USB_DIEP_CTL_STALL;
        // TODO: do we need to clear the data toggle here?
        break;

    case 0x0302: // SET_FEATURE (endpoint)
        if (setup->wIndex > 0 || setup->wValue != 0)
        {
            // TODO: do we need to handle IN vs OUT here?
            usb_stall(0x80);
            return;
        }
        // XXX: Should we set the stall bit?
        // USB->DIEP0CTL |= USB_DIEP_CTL_STALL;
        // TODO: do we need to clear the data toggle here?
        break;

    case 0x0680: // GET_DESCRIPTOR
    case 0x0681:
        for (list = usb_descriptor_list; 1; list++)
        {
            if (list->addr == NULL)
                break;
            if (setup->wValue == list->wValue)
            {
                data = list->addr;
                if ((setup->wValue >> 8) == 3)
                {
                    // for string descriptors, use the descriptor's
                    // length field, allowing runtime configured
                    // length.
                    datalen = *(list->addr);
                }
                else
                {
                    datalen = list->length;
                }
                goto send;
            }
        }
        usb_stall(0x80);
        return;

    case (MSFT_VENDOR_CODE << 8) | 0xC0: // Get Microsoft descriptor
    case (MSFT_VENDOR_CODE << 8) | 0xC1:
        if (setup->wIndex == 0x0004)
        {
            // Return WCID descriptor
            data = usb_microsoft_wcid;
            datalen = MSFT_WCID_LEN;
            break;
        }
        usb_stall(0x80);
        return;

    case (WEBUSB_VENDOR_CODE << 8) | 0xC0: // Get WebUSB descriptor
        if (setup->wIndex == 0x0002)
        {
            if (setup->wValue == 0x0001)
            {
                data = get_landing_url_descriptor(&datalen);
                break;
            }
        }
        usb_stall(0x80);
        return;

    default:
        usb_stall(0x80);
        return;
    }

send:
    if (data && datalen) {
        if (datalen > setup->wLength)
            datalen = setup->wLength;
        usb_send(0, data, datalen);
    }
    else
        usb_ack(0x80);
    return;
}
