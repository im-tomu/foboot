#include <usb.h>
#include <irq.h>
#include <generated/csr.h>
#include <string.h>
#include <printf.h>
#include <uart.h>

#ifdef CSR_USB_OBUF_EMPTY_ADDR

static const uint8_t crc5Table4[] =
        {
            0x00, 0x0E, 0x1C, 0x12, 0x11, 0x1F, 0x0D, 0x03,
            0x0B, 0x05, 0x17, 0x19, 0x1A, 0x14, 0x06, 0x08};
static const uint8_t crc5Table0[] =
        {
            0x00, 0x16, 0x05, 0x13, 0x0A, 0x1C, 0x0F, 0x19,
            0x14, 0x02, 0x11, 0x07, 0x1E, 0x08, 0x1B, 0x0D};
//---------------
static int crc5Check(const uint8_t *data)
//---------------
{
    uint8_t b = data[0] ^ 0x1F;
    uint8_t crc = crc5Table4[b & 0x0F] ^ crc5Table0[(b >> 4) & 0x0F];
    b = data[1] ^ crc;
    return (crc5Table4[b & 0x0F] ^ crc5Table0[(b >> 4) & 0x0F]) == 0x06;
}
//  crc5Check

static int do_check(uint16_t pkt) {
    uint8_t data[2] = {
        pkt >> 8,
        pkt,
    };
    return crc5Check(data);
}

#define INT_SIZE 32
static unsigned CRC5(unsigned dwInput, int iBitcnt)
{
    const uint32_t poly5 = (0x05 << (INT_SIZE-5));
    uint32_t crc5  = (0x1f << (INT_SIZE-5));
    uint32_t udata = (dwInput << (INT_SIZE-iBitcnt));

    if ( (iBitcnt<1) || (iBitcnt>INT_SIZE) )    // Validate iBitcnt
        return 0xffffffff;

    while (iBitcnt--)
    {
        if ( (udata ^ crc5) & (0x1<<(INT_SIZE-1)) ) // bit4 != bit4?
        {
            crc5 <<= 1;
            crc5 ^= poly5;
        }
        else
            crc5 <<= 1;

        udata <<= 1;
    }

    // Shift back into position
    crc5 >>= (INT_SIZE-5);

    // Invert contents to generate crc field
    crc5 ^= 0x1f;

    return crc5;
} //CRC5()

static uint32_t reverse_sof(uint32_t data) {
    int i;
    uint32_t data_flipped = 0;
    for (i = 0; i < 11; i++)
        if (data & (1 << i))
            data_flipped |= 1 << (10 - i);

    return data_flipped;
}

static uint8_t reverse_byte(uint8_t data) {
    int i;
    uint8_t data_flipped = 0;
    for (i = 0; i < 8; i++)
        if (data & (1 << i))
            data_flipped |= 1 << (7 - i);

    return data_flipped;
}

static uint8_t reverse_crc5(uint8_t data) {
    int i;
    uint8_t data_flipped = 0;
    for (i = 0; i < 5; i++)
        if (data & (1 << i))
            data_flipped |= 1 << (4 - i);

    return data_flipped;
}

static uint16_t make_token(uint16_t data) {
    uint16_t val = 0;

    data = reverse_sof(data);
    val = data << 5;
    val |= CRC5(data, 11);

    return (reverse_byte(val >> 8) << 8) | reverse_byte(val);
}

int do_crc5(uint8_t bfr[2]) {
    uint8_t pkt_flipped[2] = {
        reverse_byte(bfr[0]),
        reverse_byte(bfr[1]),
    };
    uint32_t data = (pkt_flipped[1] >> 5) | (pkt_flipped[0] << 3);
    uint32_t data_flipped;
    uint8_t crc;
    uint16_t pkt;
    ((uint8_t *)&pkt)[0] = bfr[1];
    ((uint8_t *)&pkt)[1] = bfr[0];
    uint8_t found_crc = (pkt >> 3) & 0x1f;

    data_flipped = reverse_sof(data);

    crc = CRC5(data, 11);
    crc = reverse_crc5(crc);

    uint16_t reconstructed = make_token(data_flipped);
    uint16_t wire = (reverse_byte(pkt >> 8) << 8) | reverse_byte(pkt);

    printf("Packet: 0x%04x  FCRC: %02x  Data: 0x%04x  "
    "Flipped: 0x%04x  CRC5: 0x%02x  Pass? %d  Reconstructed: 0x%04x  Wire: %04x\n",
        pkt, found_crc, data, data_flipped, crc, do_check(pkt),
        reconstructed,
        wire
        );

    return crc;
}

static const char hex[] = "0123456789abcdef";

uint8_t usb_ep0out_wr_ptr;
uint8_t usb_ep0out_rd_ptr;
#define EP0OUT_BUFFERS 64
__attribute__((aligned(4)))
static uint8_t usb_ep0out_buffer[EP0OUT_BUFFERS][128];
static uint8_t usb_ep0out_buffer_len[EP0OUT_BUFFERS];
void usb_poll(void)
{
    while (usb_ep0out_rd_ptr != usb_ep0out_wr_ptr) {
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_rd_ptr];
        uint8_t cnt = usb_ep0out_buffer_len[usb_ep0out_rd_ptr];
        unsigned int i;
        if (cnt) {
            for (i = 0; i < cnt; i++) {
                uart_write(' ');
                uart_write(hex[(obuf[i] >> 4) & 0xf]);
                uart_write(hex[obuf[i] & (0xf)]);
            }
            uart_write('\r');
            uart_write('\n');
        }
        if (obuf[0] == 0xa5) {
            do_crc5(obuf + 1);
        }
        usb_ep0out_rd_ptr = (usb_ep0out_rd_ptr + 1) & (EP0OUT_BUFFERS-1);
    }
}

int irq_happened;

void usb_init(void) {
    return;
}

void usb_isr(void) {
    uint8_t pending = usb_ev_pending_read();
    unsigned int byte_count = 0;

    // printf("Start pending: %d  byte_count: %d  empty: %d\n", pending, usb_byte_count_read(), usb_obuf_empty_read());
    // Advance the obuf head, which will reset the obuf_empty bit
    if (pending & 1) {
        uint8_t *obuf = usb_ep0out_buffer[usb_ep0out_wr_ptr];
        while (!usb_obuf_empty_read() && (byte_count < sizeof(usb_ep0out_buffer[usb_ep0out_wr_ptr]))) {
            obuf[byte_count++] = usb_obuf_head_read();
            usb_obuf_head_write(0);
        }
        usb_ep0out_buffer_len[usb_ep0out_wr_ptr] = byte_count;
        usb_ep0out_wr_ptr = (usb_ep0out_wr_ptr + 1) & (EP0OUT_BUFFERS-1);
        usb_ev_pending_write(pending);
    }
    // printf("Start pending: %d  byte_count: %d  empty: %d  bytes_read: %d\n", pending, usb_byte_count_read(), usb_obuf_empty_read(), byte_count);

    return;
}

void usb_connect(void) {
    usb_pullup_out_write(1);

    usb_ev_pending_write(usb_ev_pending_read());
    usb_ev_enable_write(1);
    usb_obuf_head_write(0);

	irq_setmask(irq_getmask() | (1 << USB_INTERRUPT));
}

int usb_irq_happened(void) {
  return irq_happened;
}

#endif /* CSR_USB_OBUF_EMPTY_ADDR */