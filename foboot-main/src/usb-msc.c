#include <stdint.h>
#include "usb-desc.h"
#include "usb-msc.h"
#include "usb.h"

static const uint8_t max_lun = 0;
#define DISK_SIZE 117760 // ~112 kilobytes
#define BLOCK_SIZE 512
#define BLOCK_COUNT (DISK_SIZE / BLOCK_SIZE)
static uint32_t memory_backing[DISK_SIZE/4];

static uint32_t swap32(uint32_t x) {
    return  ((x << 24) & 0xff000000) |
            ((x <<  8) & 0x00ff0000) |
            ((x >>  8) & 0x0000ff00) |
            ((x >> 24) & 0x000000ff);
}

static uint8_t sbc_sense_key;
static uint8_t sbc_asc;
static uint8_t sbc_ascq;

static struct usb_msc_csw csw;

static int (*usb_write_cb)(const uint8_t *data, size_t count, void *ptr);
static void *usb_write_cb_ptr = NULL;

static void set_sbc_status(enum sbc_sense_key key,
			               enum sbc_asc asc,
			               enum sbc_ascq ascq) {
	sbc_sense_key = (uint8_t) key;
	sbc_asc = (uint8_t) asc;
	sbc_ascq = (uint8_t) ascq;
}

static void set_sbc_status_good(void) {
	set_sbc_status(SBC_SENSE_KEY_NO_SENSE,
		           SBC_ASC_NO_ADDITIONAL_SENSE_INFORMATION,
		           SBC_ASCQ_NA);
}

static const char *error_reason = NULL;

static const void *parse_cbw(const void *data, size_t len, struct cbw *cbw_dest) {
    const struct cbw *cbw_src = data;
    unsigned int i;

    // Check for the signature
    uint8_t sig_test[4] = {'U', 'S', 'B', 'C'};
    for (i = 0; i < sizeof(sig_test); i++) {
        if (sig_test[i] != cbw_src->signature[i]) {
            error_reason = "Signature Mismatch";
            return NULL;
        }
    }

    // Make sure the size at least makes sense.
    if (len < sizeof(*cbw_dest)) {
        error_reason = "Too short";
        return NULL;
    }

    // Copy over data and un-swap words.
    cbw_dest->tag = cbw_src->tag; // Don't swap, since we reply with this
    cbw_dest->length = swap32(cbw_src->length);
    cbw_dest->flags = cbw_src->flags;
    cbw_dest->lun = cbw_src->lun;
    cbw_dest->cbLength = cbw_src->cbLength;

    if (!cbw_src->data) {
        error_reason = "Data NULL";
    }
    return cbw_src->data;
}

static int reply_scsi_inquiry(const void *data) {

    static struct scsi_inquiry_data udi_msc_inquiry_data = {
        .pq_pdt = SCSI_INQ_PQ_CONNECTED | SCSI_INQ_DT_DIR_ACCESS,
        .version = 2, // SCSI_INQ_VER_SPC,
        .flags1 = SCSI_INQ_RMB,
        .flags3 = SCSI_INQ_RSP_SPC2,
        .addl_len = 36 - 4, // SCSI_INQ_ADDL_LEN(sizeof(struct scsi_inquiry_data)),
        // Linux displays this; Windows shows it in Dev Mgr
        .vendor_id = "VENDOR",
        .product_id = "SOMETHING",
        .product_rev = {'1', '.', '0', '0'},
    };

    set_sbc_status_good();
    csw.dCSWDataResidue = sizeof(udi_msc_inquiry_data);

    usb_send(2, &udi_msc_inquiry_data, sizeof(udi_msc_inquiry_data));
    return 0;
}

static int reply_scsi_read_capacity(const void *payload) {
    uint8_t bfr[8];
    bfr[0] = 0xff & (BLOCK_COUNT >> 24);
    bfr[1] = 0xff & (BLOCK_COUNT >> 16);
    bfr[2] = 0xff & (BLOCK_COUNT >> 8);
    bfr[3] = 0xff & (BLOCK_COUNT >> 0);

    bfr[4] = 0xff & (BLOCK_SIZE >> 24);
    bfr[5] = 0xff & (BLOCK_SIZE >> 16);
    bfr[6] = 0xff & (BLOCK_SIZE >> 8);
    bfr[7] = 0xff & (BLOCK_SIZE >> 0);

    usb_send(2, bfr, sizeof(bfr));
    return 0;
}

static void reply_csw(struct cbw *cbw, const void *payload, int result) {
    (void)payload;
    csw.dCSWSignature = CSW_SIGNATURE;
    csw.bCSWStatus = result;
    usb_send(2, &csw, sizeof(csw));
}

static int reply_scsi_mode_sense_6(const void *payload) {
    const uint8_t *p = payload;
    uint8_t inf_bfr[4];
    // switch (p[2]) {
    // case 0x1c: // Informational
        inf_bfr[0] = 3;	/* Num bytes that follow */
        inf_bfr[1] = 0;	/* Medium Type */
        inf_bfr[2] = 0; /* Device specific param */
        inf_bfr[3] = 0;
    csw.dCSWDataResidue = 4;
        usb_send(2, inf_bfr, sizeof(inf_bfr));
    //     break;

    // case 0x01: // Error recovery
    //     break;

    // case 0x3f:
    //     break;

    // default:
    //     return 1;
    // }
    return 0;
}

static inline void memset(uint8_t *data, int val, size_t len) {
    unsigned int i;
    for (i = 0; i < len; i++)
        data[i] = val;
}

static size_t read_remaining;
static size_t read_offset;
static int csw_sent;
static int read_cb(uint8_t *bfr, size_t max, void *ptr) {
    (void)ptr;
    if (!read_remaining) {
        if (!csw_sent) {
            csw_sent = 1;
            memcpy(bfr, &csw, sizeof(csw));
            return sizeof(csw);
        }
        else {
            return -1;
        }
    }
    csw_sent = 0;
    size_t to_read = read_remaining;
    if (to_read > max)
        to_read = max;
    memcpy(bfr, ((void *)memory_backing) + read_offset, to_read);
    read_remaining -= to_read;
    read_offset += to_read;
    return to_read;
}

static int reply_scsi_read_10(const void *payload) {
    const uint8_t *p = payload;
    uint32_t lba_start = (p[2] << 24)
                       | (p[3] << 16)
                       | (p[4] << 8)
                       | (p[5] << 0);
    uint32_t block_count = (p[7] << 8) | p[8];
    read_remaining = block_count * BLOCK_SIZE;
    read_offset = lba_start * BLOCK_SIZE;
    csw.dCSWDataResidue = BLOCK_SIZE * block_count;
    usb_send_cb(2, read_cb, NULL);
    return 0;
}

static size_t write_remaining;
static size_t write_offset;
static int write_cb(const uint8_t *bfr, size_t max, void *ptr) {
    (void)ptr;

    size_t to_write = write_remaining;
    if (to_write > max)
        to_write = max;

    memcpy(((void *)memory_backing) + write_offset, bfr, to_write);
    write_remaining -= to_write;
    write_offset += to_write;

    if (!write_remaining) {
        usb_send(2, &csw, sizeof(csw));
    }
    return write_remaining;
}

static int reply_scsi_write_10(const void *payload) {
    const uint8_t *p = payload;
    uint32_t lba_start = (p[2] << 24)
                       | (p[3] << 16)
                       | (p[4] << 8)
                       | (p[5] << 0);
    uint32_t block_count = (p[7] << 8) | p[8];
    write_remaining = block_count * BLOCK_SIZE;
    write_offset = lba_start * BLOCK_SIZE;
    usb_write_cb = write_cb;
    usb_write_cb_ptr = NULL;
    return 0;
}

// Receive an OUT packet from the host
void usb_msc_out(const void *data, size_t len) {
    struct cbw cbw;
    const void *payload;
    int result;

    if (usb_write_cb) {
        int res = usb_write_cb(data, len, usb_write_cb_ptr);
        if (res > 0)
            return;
        usb_write_cb = NULL;
        usb_write_cb_ptr = NULL;
        if (res == 0)
            return;
    }

    payload = parse_cbw(data, len, &cbw);
    if (!payload) {
        usb_stall(0x82);
        return;
    }

    csw.dCSWDataResidue = 0;
    csw.dCSWTag = cbw.tag;
    const uint8_t *char_view = payload;
    switch (char_view[0]) {
    case 0x00: // TEST_UNIT_READY
        result = 0;
        break;

    case 0x12: // SCSI_INQUIRY
        result = reply_scsi_inquiry(payload);
        break;

    case 0x25: // READ_CAPACITY
        result = reply_scsi_read_capacity(payload);
        break;

    case 0x1a: // MODE_SENSE_6
        result = reply_scsi_mode_sense_6(payload);
        break;

    case 0x1e: // PREVENT_ALLOW_MEDIUM_REMOVAL
        result = 0;
        break;

    case 0x28: // READ_10
        reply_scsi_read_10(payload);
        return;

    case 0x2a: // WRITE_10
        reply_scsi_write_10(payload);
        return;

    default:
        result = 1;
        break;
    }

    reply_csw(&cbw, payload, result);
}

// Receive an IN packet from the host
void usb_msc_in(void) {
}

int usb_msc_setup(const struct usb_setup_request *setup) {
    if (setup->wRequestAndType == 0xfea1) {
        usb_send(0, &max_lun, sizeof(max_lun));
        return 1;
    }
    return 0;
}