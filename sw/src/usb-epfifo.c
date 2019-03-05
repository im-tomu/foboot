#include <grainuum.h>
#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <printf.h>
#include <uart.h>

#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR

#define NUM_BUFFERS 4
#define BUFFER_SIZE 64
#define EP_INTERVAL_MS 6

//static struct GrainuumUSB usb;
//static uint8_t usb_buf[67];
static const uint8_t hid_report_descriptor[] = {
    0x06, 0x00, 0xFF, // (GLOBAL) USAGE_PAGE         0xFF00 Vendor-defined
    0x09, 0x00,       // (LOCAL)  USAGE              0xFF000000
    0xA1, 0x01,       // (MAIN)   COLLECTION         0x01 Application (Usage=0xFF000000: Page=Vendor-defined, Usage=, Type=)
    0x26, 0xFF, 0x00, //   (GLOBAL) LOGICAL_MAXIMUM    0x00FF (255)
    0x75, 0x08,       //   (GLOBAL) REPORT_SIZE        0x08 (8) Number of bits per field
    0x95, 0x08,       //   (GLOBAL) REPORT_COUNT       0x08 (8) Number of fields
    0x06, 0xFF, 0xFF, //   (GLOBAL) USAGE_PAGE         0xFFFF Vendor-defined
    0x09, 0x01,       //   (LOCAL)  USAGE              0xFFFF0001
    0x81, 0x02,       //   (MAIN)   INPUT              0x00000002 (8 fields x 8 bits) 0=Data 1=Variable 0=Absolute 0=NoWrap 0=Linear 0=PrefState 0=NoNull 0=NonVolatile 0=Bitmap
    0x09, 0x01,       //   (LOCAL)  USAGE              0xFFFF0001
    0x91, 0x02,       //   (MAIN)   OUTPUT             0x00000002 (8 fields x 8 bits) 0=Data 1=Variable 0=Absolute 0=NoWrap 0=Linear 0=PrefState 0=NoNull 0=NonVolatile 0=Bitmap
    0xC0,             // (MAIN)   END_COLLECTION     Application
};

static const struct usb_device_descriptor device_descriptor = {
    .bLength = 18,                //sizeof(struct usb_device_descriptor),
    .bDescriptorType = DT_DEVICE, /* DEVICE */
    .bcdUSB = 0x0200,             /* USB 2.0 */
    .bDeviceClass = 0x00,
    .bDeviceSubClass = 0x00,
    .bDeviceProtocol = 0x00,
    .bMaxPacketSize0 = 0x08, /* 8-byte packets max */
    .idVendor = 0x1209,
    .idProduct = 0x9317,
    .bcdDevice = 0x0114,   /* Device release 1.14 */
    .iManufacturer = 0x02, /* No manufacturer string */
    .iProduct = 0x01,      /* Product name in string #2 */
    .iSerialNumber = 0x03, /* No serial number */
    .bNumConfigurations = 0x01,
};

static const struct usb_configuration_descriptor configuration_descriptor = {
    .bLength = 9, //sizeof(struct usb_configuration_descriptor),
    .bDescriptorType = DT_CONFIGURATION,
    .wTotalLength = (9 + /*9 + 9 + 7  +*/ 9 + 9 + 7 + 7) /*
                  (sizeof(struct usb_configuration_descriptor)
                + sizeof(struct usb_interface_descriptor)
                + sizeof(struct usb_hid_descriptor)
                + sizeof(struct usb_endpoint_descriptor)*/,
    .bNumInterfaces = 1,
    .bConfigurationValue = 1,
    .iConfiguration = 5,
    .bmAttributes = 0x80, /* Remote wakeup not supported */
    .bMaxPower = 100 / 2, /* 100 mA (in 2-mA units) */
    .data = {
        /* struct usb_interface_descriptor { */
        /*  uint8_t bLength;            */ 9,
        /*  uint8_t bDescriptorType;    */ DT_INTERFACE,
        /*  uint8_t bInterfaceNumber;   */ 0,
        /*  uint8_t bAlternateSetting;  */ 0,
        /*  uint8_t bNumEndpoints;      */ 2, /* Two extra EPs */
        /*  uint8_t bInterfaceClass;    */ 3, /* HID class */
        /*  uint8_t bInterfaceSubclass; */ 0, /* Boot Device subclass */
        /*  uint8_t bInterfaceProtocol; */ 0, /* 1 == keyboard, 2 == mouse */
        /*  uint8_t iInterface;         */ 4, /* String index #4 */
                                              /* }*/

        /* struct usb_hid_descriptor {        */
        /*  uint8_t  bLength;                 */ 9,
        /*  uint8_t  bDescriptorType;         */ DT_HID,
        /*  uint16_t bcdHID;                  */ 0x11, 0x01,
        /*  uint8_t  bCountryCode;            */ 0,
        /*  uint8_t  bNumDescriptors;         */ 1, /* We have only one REPORT */
        /*  uint8_t  bReportDescriptorType;   */ DT_HID_REPORT,
        /*  uint16_t wReportDescriptorLength; */ sizeof(hid_report_descriptor),
        sizeof(hid_report_descriptor) >> 8,
        /* }                                  */

        /* struct usb_endpoint_descriptor { */
        /*  uint8_t  bLength;             */ 7,
        /*  uint8_t  bDescriptorType;     */ DT_ENDPOINT,
        /*  uint8_t  bEndpointAddress;    */ 0x81, /* EP1 (IN) */
        /*  uint8_t  bmAttributes;        */ 3,    /* Interrupt */
        /*  uint16_t wMaxPacketSize;      */ 0x08, 0x00,
        /*  uint8_t  bInterval;           */ EP_INTERVAL_MS, /* Every 6 ms */
                                                             /* }                              */

        /* struct usb_endpoint_descriptor { */
        /*  uint8_t  bLength;             */ 7,
        /*  uint8_t  bDescriptorType;     */ DT_ENDPOINT,
        /*  uint8_t  bEndpointAddress;    */ 0x01, /* EP1 (OUT) */
        /*  uint8_t  bmAttributes;        */ 3,    /* Interrupt */
        /*  uint16_t wMaxPacketSize;      */ 0x08, 0x00,
        /*  uint8_t  bInterval;           */ EP_INTERVAL_MS, /* Every 6 ms */
                                                             /* }                              */
    },
};

enum epfifo_response {
    EPF_ACK = 0,
    EPF_NAK = 1,
    EPF_NONE = 2,
    EPF_STALL = 3,
};

#define USB_EV_ERROR 1
#define USB_EV_PACKET 2

void usb_connect(void) {
    usb_pullup_out_write(1);

    // By default, it wants to respond with NAK.
    usb_ep_0_out_respond_write(EPF_ACK);
    usb_ep_0_in_respond_write(EPF_NAK);

    usb_ep_0_out_ev_pending_write(usb_ep_0_out_ev_enable_read());
    usb_ep_0_in_ev_pending_write(usb_ep_0_in_ev_pending_read());
    usb_ep_0_out_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);
    usb_ep_0_in_ev_enable_write(USB_EV_PACKET | USB_EV_ERROR);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

void usb_init(void) {
    return;
}

volatile int irq_count = 0;

#define EP0OUT_BUFFERS 64
static uint8_t usb_ep0out_buffer[EP0OUT_BUFFERS][128];
uint8_t usb_ep0out_wr_ptr;
uint8_t usb_ep0out_rd_ptr;
int descriptor_ptr;
int max_byte_length = 8;

static const uint8_t *current_data;
static int current_length;
static int current_offset;
static int current_to_send;

static int maybe_send_more_data(int epnum) {
    (void)epnum;
    // Don't allow requeueing
    if (usb_ep_0_in_respond_read() != EPF_NAK)
        return -1;

    int this_offset;
    current_to_send = current_length - current_offset;
    if (current_to_send > max_byte_length)
        current_to_send = max_byte_length;

    for (this_offset = current_offset; this_offset < current_offset + current_to_send; this_offset++) {
        usb_ep_0_in_ibuf_head_write(current_data[this_offset]);
    }
    usb_ep_0_in_respond_write(EPF_ACK);
    usb_ep_0_out_respond_write(EPF_ACK);
    return 0;
}

static int send_data(int epnum, const void *data, int total_count) {
    // Don't allow requeueing
    if (usb_ep_0_in_respond_read() != EPF_NAK)
        return -1;
    current_data = (uint8_t *)data;
    current_length = total_count;
    current_offset = 0;
    maybe_send_more_data(epnum);
    return 0;
}

void usb_isr(void) {
    irq_count++;

    uint8_t ep0o_pending = usb_ep_0_out_ev_pending_read();
    uint8_t ep0i_pending = usb_ep_0_in_ev_pending_read();

    if (ep0o_pending) {
        int byte_count = 0;
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (1) {
            if (usb_ep_0_out_obuf_empty_read())
                break;
            obuf[++byte_count] = usb_ep_0_out_obuf_head_read();
            usb_ep_0_out_obuf_head_write(0);
        }
        usb_ep_0_out_ev_pending_write(ep0o_pending);

        if (byte_count) {
            obuf[0] = byte_count;
            usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);

            // usb_ep_0_in_dtb_write(1);
            send_data(0, &device_descriptor, sizeof(device_descriptor));
        }
        else {
            usb_ep_0_out_respond_write(EPF_ACK);
        }
    }

    if (ep0i_pending) {
        /*
        uint8_t *descriptor = (uint8_t *)&device_descriptor;
        if (descriptor_ptr < 0) {
            usb_ep_0_in_respond_write(EPF_NAK);
        }
        else if (descriptor_ptr >= sizeof(device_descriptor)) {
            descriptor_ptr = -1;
            usb_ep_0_in_respond_write(EPF_ACK);
        }
        else {
            usb_ep_0_in_respond_write(EPF_NAK);
            for (descriptor_ptr; descriptor_ptr < sizeof(device_descriptor); descriptor_ptr++) {
                usb_ep_0_in_ibuf_head_write(descriptor[descriptor_ptr]);
            }
            usb_ep_0_in_respond_write(EPF_ACK);
        }
        */
        usb_ep_0_in_respond_write(EPF_NAK);
        current_offset += current_to_send;
        maybe_send_more_data(0);
        usb_ep_0_in_ev_pending_write(ep0i_pending);

        // Get ready to respond to the empty data byte
        usb_ep_0_out_respond_write(EPF_ACK);
    }

    return;
}

void usb_wait(void) {
    while (!irq_count)
        ;
}

int usb_irq_happened(void) {
  return irq_count;
}

static const char hex[] = "0123456789abcdef";
void usb_print_status(void) {
    /*
    printf("EP0_OUT  Status:     %02x\n", usb_ep_0_out_ev_status_read());
    printf("EP0_OUT  Pending:    %02x\n", usb_ep_0_out_ev_pending_read());
    printf("EP0_OUT  Enable:     %02x\n", usb_ep_0_out_ev_enable_read());
    printf("EP0_OUT  Last Tok:   %02x\n", usb_ep_0_out_last_tok_read());
    printf("EP0_OUT  Respond:    %02x\n", usb_ep_0_out_respond_read());
    printf("EP0_OUT  DTB:        %02x\n", usb_ep_0_out_dtb_read());
    printf("EP0_OUT  OBUF Head:  %02x\n", usb_ep_0_out_obuf_head_read());
    printf("EP0_OUT  OBUF Empty: %02x\n", usb_ep_0_out_obuf_empty_read());
    printf("EP0_IN   Status:     %02x\n", usb_ep_0_in_ev_status_read());
    printf("EP0_IN   Pending:    %02x\n", usb_ep_0_in_ev_pending_read());
    printf("EP0_IN   Enable:     %02x\n", usb_ep_0_in_ev_enable_read());
    printf("EP0_IN   Last Tok:   %02x\n", usb_ep_0_in_last_tok_read());
    printf("EP0_IN   Respond:    %02x\n", usb_ep_0_in_respond_read());
    printf("EP0_IN   DTB:        %02x\n", usb_ep_0_in_dtb_read());
    printf("EP0_IN   IBUF Head:  %02x\n", usb_ep_0_in_ibuf_head_read());
    printf("EP0_IN   IBUF Empty: %02x\n", usb_ep_0_in_ibuf_empty_read());
    */
    while (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        // printf("for (this_offset = current_offset; this_offset < this_offset + current_to_send; this_offset++) {\n");
        // printf("for (this_offset = %d; this_offset < %d; %d++) {\n", current_offset, this_offset, this_offset + current_to_send, this_offset);
        printf("current_data: 0x%08x\n", current_data);
        printf("current_length: %d\n", current_length);
        printf("current_offset: %d\n", current_offset);
        printf("current_to_send: %d\n", current_to_send);
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_rd_ptr];
        uint8_t cnt = obuf[0];
        unsigned int i;
        if (cnt) {
            for (i = 0; i < cnt; i++) {
                uart_write(' ');
                uart_write(hex[(obuf[i+1] >> 4) & 0xf]);
                uart_write(hex[obuf[i+1] & (0xf)]);
                // printf(" %02x", obufbuf[i]);
            }
            uart_write('\r');
            uart_write('\n');
        }
        // printf("\n");
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
    }
}


// static inline unsigned char usb_pullup_out_read(void);
// static inline void usb_pullup_out_write(unsigned char value);


// static inline unsigned char usb_ep_0_out_ev_status_read(void);
// static inline void usb_ep_0_out_ev_status_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_ev_pending_read(void);
// static inline void usb_ep_0_out_ev_pending_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_ev_enable_read(void);
// static inline void usb_ep_0_out_ev_enable_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_last_tok_read(void);

// static inline unsigned char usb_ep_0_out_respond_read(void);
// static inline void usb_ep_0_out_respond_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_dtb_read(void);
// static inline void usb_ep_0_out_dtb_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_obuf_head_read(void);
// static inline void usb_ep_0_out_obuf_head_write(unsigned char value);

// static inline unsigned char usb_ep_0_out_obuf_empty_read(void);


// static inline unsigned char usb_ep_0_in_ev_status_read(void);
// static inline void usb_ep_0_in_ev_status_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_ev_pending_read(void);
// static inline void usb_ep_0_in_ev_pending_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_ev_enable_read(void);
// static inline void usb_ep_0_in_ev_enable_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_last_tok_read(void);

// static inline unsigned char usb_ep_0_in_respond_read(void);
// static inline void usb_ep_0_in_respond_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_dtb_read(void);
// static inline void usb_ep_0_in_dtb_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_ibuf_head_read(void);
// static inline void usb_ep_0_in_ibuf_head_write(unsigned char value);

// static inline unsigned char usb_ep_0_in_ibuf_empty_read(void);
  

#if 0
static uint32_t rx_buffer[NUM_BUFFERS][BUFFER_SIZE / sizeof(uint32_t)];
static uint8_t rx_buffer_head;
static uint8_t rx_buffer_tail;

static uint32_t rx_buffer_queries = 0;
static void set_usb_config_num(struct GrainuumUSB *usb, int configNum)
{
  (void)usb;
  (void)configNum;
  ;
}


#define USB_STR_BUF_LEN 64

static uint32_t str_buf_storage[USB_STR_BUF_LEN / sizeof(uint32_t)];
static int send_string_descriptor(const char *str, const void **data)
{
  int len;
  int max_len;
  uint8_t *str_buf = (uint8_t *)str_buf_storage;
  uint8_t *str_offset = str_buf;

  len = strlen(str);
  max_len = (USB_STR_BUF_LEN / 2) - 2;

  if (len > max_len)
    len = max_len;

  *str_offset++ = (len * 2) + 2; // Two bytes for length count
  *str_offset++ = DT_STRING;     // Sending a string descriptor

  while (len--)
  {
    *str_offset++ = *str++;
    *str_offset++ = 0;
  }

  *data = str_buf;

  // Return the size, which is stored in the first byte of the output data.
  return str_buf[0];
}

static int get_string_descriptor(struct GrainuumUSB *usb,
                                 uint32_t num,
                                 const void **data)
{

  static const uint8_t en_us[] = {0x04, DT_STRING, 0x09, 0x04};

  (void)usb;

  if (num == 0)
  {
    *data = en_us;
    return sizeof(en_us);
  }

  // Product
  if (num == 1)
    return send_string_descriptor("Palawan Bootloader", data);

  if (num == 2)
    return send_string_descriptor("21", data);

  if (num == 3)
    return send_string_descriptor("1236", data);

  if (num == 4)
    return send_string_descriptor("12345", data);

  if (num == 5)
    return send_string_descriptor("54", data);

  if (num == 6)
    return send_string_descriptor("12345678901234", data);

  return 0;
}

static int get_device_descriptor(struct GrainuumUSB *usb,
                                 uint32_t num,
                                 const void **data)
{

  (void)usb;

  if (num == 0)
  {
    *data = &device_descriptor;
    return sizeof(device_descriptor);
  }
  return 0;
}

static int get_hid_report_descriptor(struct GrainuumUSB *usb,
                                     uint32_t num,
                                     const void **data)
{

  (void)usb;

  if (num == 0)
  {
    *data = &hid_report_descriptor;
    return sizeof(hid_report_descriptor);
  }

  return 0;
}

static int get_configuration_descriptor(struct GrainuumUSB *usb,
                                        uint32_t num,
                                        const void **data)
{

  (void)usb;

  if (num == 0)
  {
    *data = &configuration_descriptor;
    return configuration_descriptor.wTotalLength;
  }
  return 0;
}

static int get_descriptor(struct GrainuumUSB *usb,
                          const void *packet,
                          const void **response)
{

  const struct usb_setup_packet *setup = packet;
  printf("In get_Descriptor()\n");
  switch (setup->wValueH)
  {
  case DT_DEVICE:
    printf("Returning device descriptor %d\n", setup->wValueL);
    return get_device_descriptor(usb, setup->wValueL, response);

  case DT_STRING:
    printf("Returning string descriptor %d\n", setup->wValueL);
    return get_string_descriptor(usb, setup->wValueL, response);

  case DT_CONFIGURATION:
    printf("Returning configuration descriptor %d\n", setup->wValueL);
    return get_configuration_descriptor(usb, setup->wValueL, response);

  case DT_HID_REPORT:
    printf("Returning HID descriptor %d\n", setup->wValueL);
    return get_hid_report_descriptor(usb, setup->wValueL, response);
  }

  printf("Returning no descriptor %d\n", setup->wValueL);

  return 0;
}

static void *get_usb_rx_buffer(struct GrainuumUSB *usb,
                               uint8_t epNum,
                               int32_t *size)
{
  (void)usb;
  (void)epNum;

  if (size)
    *size = sizeof(rx_buffer[0]);
  rx_buffer_queries++;
  return rx_buffer[rx_buffer_head];
}

static int received_data(struct GrainuumUSB *usb,
                         uint8_t epNum,
                         uint32_t bytes,
                         const void *data)
{
  (void)usb;
  (void)epNum;
  (void)bytes;
  (void)data;

  if (epNum == 1)
  {
    rx_buffer_head = (rx_buffer_head + 1) & (NUM_BUFFERS - 1);
  }

  /* Return 0, indicating this packet is complete. */
  return 0;
}

static int send_data_finished(struct GrainuumUSB *usb, int result)
{
  (void)usb;
  (void)result;

  return 0;
}

static struct GrainuumConfig cfg = {
    .getDescriptor = get_descriptor,
    .getReceiveBuffer = get_usb_rx_buffer,
    .receiveData = received_data,
    .sendDataFinished = send_data_finished,
    .setConfigNum = set_usb_config_num,
};

// void usb_isr(void) {
//     // grainuumCaptureI(&usb, usb_buf);
//     return;
// }

// void usb_init(void) {
//     // grainuumInit(&usb, &cfg);
//     // grainuumConnect(&usb);
//     return;
// }

void usbPhyWriteI(const struct GrainuumUSB *usb, const void *buffer, uint32_t size) {
    // (void)usb;
    // const uint8_t *ubuffer = (const uint8_t *)buffer;
    // uint32_t i = 0;
    // while (i < size)
    //     usb_obuf_head_write(ubuffer[i]);
}

int usbPhyReadI(const struct GrainuumUSB *usb, uint8_t *samples) {
    (void)usb;
    int count = 0;
    // while (!usb_ibuf_empty_read()) {
        // samples[count++] = usb_ibuf_head_read();
    // }
    return count;
}
#endif
#endif /* CSR_USB_EP_0_OUT_EV_PENDING_ADDR */