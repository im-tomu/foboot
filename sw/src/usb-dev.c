#include <stdint.h>
#include <unistd.h>
#include <usb.h>
#include <dfu.h>

#include <printf.h>

#include <usb-desc.h>

static uint8_t reply_buffer[8];
static uint8_t usb_configuration = 0;
#define USB_MAX_PACKET_SIZE 64 /* For FS device */
static uint8_t rx_buffer[USB_MAX_PACKET_SIZE];

void usb_setup(struct usb_device *dev, const struct usb_setup_request *setup)
{
    const uint8_t *data = NULL;
    uint32_t datalen = 0;
    const usb_descriptor_list_t *list;

    // printf("%s:%d SETUP packet (%04x) value: %02x index: %02x\n", __FILE__, __LINE__, setup->wRequestAndType, setup->wIndex, setup->wValue);

    switch (setup->wRequestAndType)
    {
    case 0x0500: // SET_ADDRESS
        // TODO: Handle set_daddr
        // efm32hg_set_daddr(setup->wValue);
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
            printf("get_status (setup->wIndex: %d)\n", setup->wIndex);
            usb_err(dev, 0);
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
            printf("%s:%d clear feature (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
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
            printf("%s:%d clear feature (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
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
            i++;
        }
        printf("%s:%d couldn't find descriptor %04x (%d / %d)\n", __FILE__, __LINE__, setup->wValue, setup->wIndex, setup->wValue);
        usb_err(dev, 0);
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
        printf("%s:%d couldn't find microsoft descriptor (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
        usb_err(dev, 0);
        return;

    case (WEBUSB_VENDOR_CODE << 8) | 0xC0: // Get WebUSB descriptor
        if (setup->wIndex == 0x0002)
        {
            if (setup->wValue == 0x0001)
            {
                // Return landing page URL descriptor
                data = (uint8_t*)&landing_url_descriptor;
                datalen = LANDING_PAGE_DESCRIPTOR_SIZE;
                break;
            }
        }
        printf("%s:%d couldn't find webusb descriptor (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
        usb_err(dev, 0);
        return;

    case 0x0121: // DFU_DNLOAD
        if (setup->wIndex > 0)
        {
            printf("%s:%d dfu download descriptor index invalid (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        // Data comes in the OUT phase. But if it's a zero-length request, handle it now.
        if (setup->wLength == 0)
        {
            if (!dfu_download(setup->wValue, 0, 0, 0, NULL))
            {
                usb_err(dev, 0);
                return;
            }
            usb_ack(dev, 0);
            return;
        }
        unsigned int len = setup->wLength;
        if (len > sizeof(rx_buffer))
            len = sizeof(rx_buffer);
        usb_recv(dev, rx_buffer, len);
        return;

    case 0x03a1: // DFU_GETSTATUS
        if (setup->wIndex > 0)
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        if (dfu_getstatus(reply_buffer))
        {
            data = reply_buffer;
            datalen = 6;
            break;
        }
        else
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        break;

    case 0x0421: // DFU_CLRSTATUS
        if (setup->wIndex > 0)
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        if (dfu_clrstatus())
        {
            break;
        }
        else
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }

    case 0x05a1: // DFU_GETSTATE
        if (setup->wIndex > 0)
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        reply_buffer[0] = dfu_getstate();
        data = reply_buffer;
        datalen = 1;
        break;

    case 0x0621: // DFU_ABORT
        if (setup->wIndex > 0)
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }
        if (dfu_abort())
        {
            break;
        }
        else
        {
            printf("%s:%d err (%d / %d)\n", __FILE__, __LINE__, setup->wIndex, setup->wValue);
            usb_err(dev, 0);
            return;
        }

    default:
        printf("%s:%d unrecognized request type (%04x) value: %02x index: %02x\n", __FILE__, __LINE__, setup->wRequestAndType, setup->wIndex, setup->wValue);
        usb_err(dev, 0);
        return;
    }

send:
    if (data && datalen) {
        if (datalen > setup->wLength)
            datalen = setup->wLength;
        usb_send(dev, 0, data, datalen);
    }
    else
        usb_ack(dev, 0);
    return;
}
