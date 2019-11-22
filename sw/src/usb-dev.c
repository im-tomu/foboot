#include <stdint.h>
#include <unistd.h>
#include <usb.h>
#include <dfu.h>
#include <system.h>

#include <usb-desc.h>
#include <generated/csr.h>

static uint8_t reply_buffer[8];
static uint8_t usb_configuration = 0;
#define USB_MAX_PACKET_SIZE 64
static uint32_t rx_buffer[USB_MAX_PACKET_SIZE/4];

void usb_setup(const struct usb_setup_request *setup)
{
    uint8_t ep_dir = setup->bmRequestType >> 7;
    const uint8_t *data = NULL;
    uint32_t datalen = 0;
    const usb_descriptor_list_t *list;

    switch (setup->wRequestAndType)
    {
    case 0x0500: // SET_ADDRESS
        usb_set_address(setup->wValue >> 0);
        break;

    case 0x0b01: // SET_INTERFACE
        dfu_clrstatus();
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
            usb_err(ep_dir);
            return;
        }
        reply_buffer[0] = 0;
        reply_buffer[1] = 0;
        data = reply_buffer;
        datalen = 2;
        break;

    case 0x0102: // CLEAR_FEATURE (endpoint)
        if (setup->wIndex > 0 || setup->wValue != 0)
        {
            usb_err(ep_dir);
            return;
        }
        break;

    case 0x0302: // SET_FEATURE (endpoint)
        if (setup->wIndex > 0 || setup->wValue != 0)
        {
            usb_err(ep_dir);
            return;
        }
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
        usb_err(ep_dir);
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
        usb_err(ep_dir);
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
        usb_err(ep_dir);
        return;

    case 0x0121: // DFU_DNLOAD
        if (setup->wIndex > 0)
        {
            usb_err(ep_dir);
            return;
        }
        // Data comes in the OUT phase. But if it's a zero-length request, handle it now.
        if (setup->wLength == 0)
        {
            if (!dfu_download(setup->wValue, 0, 0, 0, NULL))
            {
                usb_err(ep_dir);
                return;
            }
            usb_ack(!ep_dir);
            return;
        }

        int bytes_remaining = setup->wLength;
        int ep0_rx_offset = 0;
        // Fill the buffer, or if there is enough space transfer the whole packet.
        unsigned int blockLength = setup->wLength;
        unsigned int blockNum = setup->wValue;

        while (bytes_remaining > 0) {
            int len = blockLength;
            if (len > (int) sizeof(rx_buffer))
                len = sizeof(rx_buffer);

            // Receive DATA packets (which are automatically ACKed)
            len = usb_recv((void *)rx_buffer, len);
            if (len == -1) {
                return;
            }

            // Append the data to the download buffer.
            dfu_download(blockNum, blockLength, ep0_rx_offset, len, (void *)rx_buffer);

            if (len > bytes_remaining)
                bytes_remaining = 0;
            else
                bytes_remaining -= len;
            ep0_rx_offset += len;
        }

        // ACK the final IN packet.
        usb_ack(1);

        return;

    case 0x0021: // DFU_DETACH
        // Send the "ACK" packet and wait for it
        // to be received.
        usb_ack(1);
        usb_wait_for_send_done();
        reboot();
        while (1)
           ;
        return;

    case 0x03a1: // DFU_GETSTATUS
        if (setup->wIndex > 0)
        {
            usb_err(ep_dir);
            return;
        }
        if (dfu_getstatus(reply_buffer))
        {
            data = reply_buffer;
            datalen = 6;
            // If the state is dfuMANIFEST-WAIT-RESET, then perform a reset
            // once the host acknowledges the packet.
            if (reply_buffer[4] == 8) {
                usb_send(0, data, datalen);
                usb_recv((void *)rx_buffer, sizeof(rx_buffer));
                reboot();
            }
            break;
        }
        else
        {
            usb_err(ep_dir);
            return;
        }
        break;

    case 0x0421: // DFU_CLRSTATUS
        if (setup->wIndex > 0)
        {
            usb_err(ep_dir);
            return;
        }
        if (dfu_clrstatus())
        {
            break;
        }
        else
        {
            usb_err(ep_dir);
            return;
        }

    case 0x05a1: // DFU_GETSTATE
        if (setup->wIndex > 0)
        {
            usb_err(ep_dir);
            return;
        }
        reply_buffer[0] = dfu_getstate();
        data = reply_buffer;
        datalen = 1;
        break;

    case 0x0621: // DFU_ABORT
        if (setup->wIndex > 0)
        {
            usb_err(ep_dir);
            return;
        }
        if (dfu_abort())
        {
            break;
        }
        else
        {
            usb_err(ep_dir);
            return;
        }

    default:
        usb_err(ep_dir);
        return;
    }

send:
    if (data && datalen) {
        if (datalen > setup->wLength)
            datalen = setup->wLength;
        usb_send(0, data, datalen);
        usb_ack(!ep_dir);
    }
    else
        usb_ack(!ep_dir);
    return;
}
