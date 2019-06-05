#ifndef USB_MSC_H
#define USB_MSC_H

#include <stdint.h>

/* The sense codes */
enum sbc_sense_key {
	SBC_SENSE_KEY_NO_SENSE			= 0x00,
	SBC_SENSE_KEY_RECOVERED_ERROR		= 0x01,
	SBC_SENSE_KEY_NOT_READY			= 0x02,
	SBC_SENSE_KEY_MEDIUM_ERROR		= 0x03,
	SBC_SENSE_KEY_HARDWARE_ERROR		= 0x04,
	SBC_SENSE_KEY_ILLEGAL_REQUEST		= 0x05,
	SBC_SENSE_KEY_UNIT_ATTENTION		= 0x06,
	SBC_SENSE_KEY_DATA_PROTECT		= 0x07,
	SBC_SENSE_KEY_BLANK_CHECK		= 0x08,
	SBC_SENSE_KEY_VENDOR_SPECIFIC		= 0x09,
	SBC_SENSE_KEY_COPY_ABORTED		= 0x0A,
	SBC_SENSE_KEY_ABORTED_COMMAND		= 0x0B,
	SBC_SENSE_KEY_VOLUME_OVERFLOW		= 0x0D,
	SBC_SENSE_KEY_MISCOMPARE		= 0x0E
};

enum sbc_asc {
	SBC_ASC_NO_ADDITIONAL_SENSE_INFORMATION	= 0x00,
	SBC_ASC_PERIPHERAL_DEVICE_WRITE_FAULT	= 0x03,
	SBC_ASC_LOGICAL_UNIT_NOT_READY		= 0x04,
	SBC_ASC_UNRECOVERED_READ_ERROR		= 0x11,
	SBC_ASC_INVALID_COMMAND_OPERATION_CODE	= 0x20,
	SBC_ASC_LBA_OUT_OF_RANGE		= 0x21,
	SBC_ASC_INVALID_FIELD_IN_CDB		= 0x24,
	SBC_ASC_WRITE_PROTECTED			= 0x27,
	SBC_ASC_NOT_READY_TO_READY_CHANGE	= 0x28,
	SBC_ASC_FORMAT_ERROR			= 0x31,
	SBC_ASC_MEDIUM_NOT_PRESENT		= 0x3A
};

enum sbc_ascq {
	SBC_ASCQ_NA				= 0x00,
	SBC_ASCQ_FORMAT_COMMAND_FAILED		= 0x01,
	SBC_ASCQ_INITIALIZING_COMMAND_REQUIRED	= 0x02,
	SBC_ASCQ_OPERATION_IN_PROGRESS		= 0x07
};

/**
 * \brief SCSI Standard Inquiry data structure
 */
struct scsi_inquiry_data {
	uint8_t pq_pdt;                      /**< Peripheral Qual / Peripheral Dev Type */
#define SCSI_INQ_PQ_CONNECTED 0x00       /**< Peripheral connected */
#define SCSI_INQ_PQ_NOT_CONN 0x20        /**< Peripheral not connected */
#define SCSI_INQ_PQ_NOT_SUPP 0x60        /**< Peripheral not supported */
#define SCSI_INQ_DT_DIR_ACCESS 0x00      /**< Direct Access (SBC) */
#define SCSI_INQ_DT_SEQ_ACCESS 0x01      /**< Sequential Access */
#define SCSI_INQ_DT_PRINTER 0x02         /**< Printer */
#define SCSI_INQ_DT_PROCESSOR 0x03       /**< Processor device */
#define SCSI_INQ_DT_WRITE_ONCE 0x04      /**< Write-once device */
#define SCSI_INQ_DT_CD_DVD 0x05          /**< CD/DVD device */
#define SCSI_INQ_DT_OPTICAL 0x07         /**< Optical Memory */
#define SCSI_INQ_DT_MC 0x08              /**< Medium Changer */
#define SCSI_INQ_DT_ARRAY 0x0c           /**< Storage Array Controller */
#define SCSI_INQ_DT_ENCLOSURE 0x0d       /**< Enclosure Services */
#define SCSI_INQ_DT_RBC 0x0e             /**< Simplified Direct Access */
#define SCSI_INQ_DT_OCRW 0x0f            /**< Optical card reader/writer */
#define SCSI_INQ_DT_BCC 0x10             /**< Bridge Controller Commands */
#define SCSI_INQ_DT_OSD 0x11             /**< Object-based Storage */
#define SCSI_INQ_DT_NONE 0x1f            /**< No Peripheral */
	uint8_t flags1;                      /**< Flags (byte 1) */
#define SCSI_INQ_RMB 0x80                /**< Removable Medium */
	uint8_t version;                     /**< Version */
#define SCSI_INQ_VER_NONE 0x00           /**< No standards conformance */
#define SCSI_INQ_VER_SPC 0x03            /**< SCSI Primary Commands     (link to SBC) */
#define SCSI_INQ_VER_SPC2 0x04           /**< SCSI Primary Commands - 2 (link to SBC-2) */
#define SCSI_INQ_VER_SPC3 0x05           /**< SCSI Primary Commands - 3 (link to SBC-2) */
#define SCSI_INQ_VER_SPC4 0x06           /**< SCSI Primary Commands - 4 (link to SBC-3) */
	uint8_t flags3;                      /**< Flags (byte 3) */
#define SCSI_INQ_NORMACA 0x20            /**< Normal ACA Supported */
#define SCSI_INQ_HISUP 0x10              /**< Hierarchal LUN addressing */
#define SCSI_INQ_RSP_SPC2 0x02           /**< SPC-2 / SPC-3 response format */
	uint8_t addl_len;                    /**< Additional Length (n-4) */
#define SCSI_INQ_ADDL_LEN(tot) ((tot)-5) /**< Total length is \a tot */
	uint8_t flags5;                      /**< Flags (byte 5) */
#define SCSI_INQ_SCCS 0x80
	uint8_t flags6; /**< Flags (byte 6) */
#define SCSI_INQ_BQUE 0x80
#define SCSI_INQ_ENCSERV 0x40
#define SCSI_INQ_MULTIP 0x10
#define SCSI_INQ_MCHGR 0x08
#define SCSI_INQ_ADDR16 0x01
	uint8_t flags7; /**< Flags (byte 7) */
#define SCSI_INQ_WBUS16 0x20
#define SCSI_INQ_SYNC 0x10
#define SCSI_INQ_LINKED 0x08
#define SCSI_INQ_CMDQUE 0x02
	uint8_t vendor_id[8];   /**< T10 Vendor Identification */
	uint8_t product_id[16]; /**< Product Identification */
	uint8_t product_rev[4]; /**< Product Revision Level */
} __attribute__((packed));


/* Command Status Wrapper */
#define CSW_SIGNATURE				0x53425355
#define CSW_STATUS_SUCCESS			0
#define CSW_STATUS_FAILED			1
#define CSW_STATUS_PHASE_ERROR	2

struct usb_msc_csw {
	uint32_t dCSWSignature;
	uint32_t dCSWTag;
	uint32_t dCSWDataResidue;
	uint8_t  bCSWStatus;
} __attribute__((packed));

struct cbw {
    // 'USBC'
    uint8_t signature[4];
    uint32_t tag;
    uint32_t length;
    uint8_t flags;
    uint8_t lun;
    uint8_t cbLength;
    uint8_t data[0];
};

int usb_msc_setup(const struct usb_setup_request *setup);
void usb_msc_in(void);
void usb_msc_out(const void *data, size_t len);

#endif // USB_MSC_H