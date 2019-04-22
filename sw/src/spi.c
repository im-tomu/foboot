#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <generated/csr.h>

#include "spi.h"

#define fprintf(...) do {} while(0)

static uint8_t do_mirror;
static uint8_t oe_mirror;

#define PI_OUTPUT 1
#define PI_INPUT 0
#define PI_ALT0 PI_INPUT
static void gpioSetMode(int pin, int mode) {
    if (mode)
        oe_mirror |= 1 << pin;
    else
        oe_mirror &= ~(1 << pin);
    picorvspi_cfg2_write(oe_mirror);
}

static void gpioWrite(int pin, int val) {
    if (val)
        do_mirror |= 1 << pin;
    else
        do_mirror &= ~(1 << pin);
    picorvspi_cfg1_write(do_mirror);
}

static int gpioRead(int pin) {
    return !!(picorvspi_stat1_read() & (1 << pin));
}

static void gpioSync(void) {
    // bbspi_do_write(do_mirror);
}

#define SPI_ONLY_SINGLE

enum ff_spi_quirks {
	// There is no separate "Write SR 2" command.  Instead,
	// you must write SR2 after writing SR1
	SQ_SR2_FROM_SR1    = (1 << 0),

	// Don't issue a "Write Enable" command prior to writing
	// a status register
	SQ_SKIP_SR_WEL     = (1 << 1),

	// Security registers are shifted up by 4 bits
	SQ_SECURITY_NYBBLE_SHIFT = (1 << 2),
};

struct ff_spi {
	enum spi_state state;
	enum spi_type type;
	enum spi_type desired_type;
	struct spi_id id;
	enum ff_spi_quirks quirks;
	int size_override;

	struct {
		int clk;
		int d0;
		int d1;
		int d2;
		int d3;
		int wp;
		int hold;
		int cs;
		int miso;
		int mosi;
	} pins;
};

static void spi_get_id(struct ff_spi *spi);

static void spi_set_state(struct ff_spi *spi, enum spi_state state) {
	return;
	if (spi->state == state)
		return;
#ifndef SPI_ONLY_SINGLE
	switch (state) {
	case SS_SINGLE:
#endif
		gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
		gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
		gpioSetMode(spi->pins.mosi, PI_OUTPUT); // MOSI
		gpioSetMode(spi->pins.miso, PI_INPUT); // MISO
		gpioSetMode(spi->pins.hold, PI_OUTPUT);
		gpioSetMode(spi->pins.wp, PI_OUTPUT);
#ifndef SPI_ONLY_SINGLE
		break;

	case SS_DUAL_RX:
		gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
		gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
		gpioSetMode(spi->pins.mosi, PI_INPUT); // MOSI
		gpioSetMode(spi->pins.miso, PI_INPUT); // MISO
		gpioSetMode(spi->pins.hold, PI_OUTPUT);
		gpioSetMode(spi->pins.wp, PI_OUTPUT);
		break;

	case SS_DUAL_TX:
		gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
		gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
		gpioSetMode(spi->pins.mosi, PI_OUTPUT); // MOSI
		gpioSetMode(spi->pins.miso, PI_OUTPUT); // MISO
		gpioSetMode(spi->pins.hold, PI_OUTPUT);
		gpioSetMode(spi->pins.wp, PI_OUTPUT);
		break;

	case SS_QUAD_RX:
		gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
		gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
		gpioSetMode(spi->pins.mosi, PI_INPUT); // MOSI
		gpioSetMode(spi->pins.miso, PI_INPUT); // MISO
		gpioSetMode(spi->pins.hold, PI_INPUT);
		gpioSetMode(spi->pins.wp, PI_INPUT);
		break;

	case SS_QUAD_TX:
		gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
		gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
		gpioSetMode(spi->pins.mosi, PI_OUTPUT); // MOSI
		gpioSetMode(spi->pins.miso, PI_OUTPUT); // MISO
		gpioSetMode(spi->pins.hold, PI_OUTPUT);
		gpioSetMode(spi->pins.wp, PI_OUTPUT);
		break;

	case SS_HARDWARE:
		gpioSetMode(spi->pins.clk, PI_ALT0); // CLK
		gpioSetMode(spi->pins.cs, PI_ALT0); // CE0#
		gpioSetMode(spi->pins.mosi, PI_ALT0); // MOSI
		gpioSetMode(spi->pins.miso, PI_ALT0); // MISO
		gpioSetMode(spi->pins.hold, PI_OUTPUT);
		gpioSetMode(spi->pins.wp, PI_OUTPUT);
		break;

	default:
		fprintf(stderr, "Unrecognized spi state\n");
		return;
	}
#endif
	spi->state = state;
}

void spiPause(struct ff_spi *spi) {
	(void)spi;
	gpioSync();
//	usleep(1);
	return;
}

void spiBegin(struct ff_spi *spi) {
	spi_set_state(spi, SS_SINGLE);
	if ((spi->type == ST_SINGLE) || (spi->type == ST_DUAL)) {
		gpioWrite(spi->pins.wp, 1);
		gpioWrite(spi->pins.hold, 1);
	}
	gpioWrite(spi->pins.cs, 0);
}

void spiEnd(struct ff_spi *spi) {
	(void)spi;
	gpioWrite(spi->pins.cs, 1);
}

static uint8_t spiXfer(struct ff_spi *spi, uint8_t out) {
	int bit;
	uint8_t in = 0;

	for (bit = 7; bit >= 0; bit--) {
		if (out & (1 << bit)) {
			gpioWrite(spi->pins.mosi, 1);
		}
		else {
			gpioWrite(spi->pins.mosi, 0);
		}
		gpioWrite(spi->pins.clk, 1);
		spiPause(spi);
		in |= ((!!gpioRead(spi->pins.miso)) << bit);
		gpioWrite(spi->pins.clk, 0);
		spiPause(spi);
	}

	return in;
}

static void spiSingleTx(struct ff_spi *spi, uint8_t out) {
	spi_set_state(spi, SS_SINGLE);
	spiXfer(spi, out);
}

static uint8_t spiSingleRx(struct ff_spi *spi) {
	spi_set_state(spi, SS_SINGLE);
	return spiXfer(spi, 0xff);
}

static void spiDualTx(struct ff_spi *spi, uint8_t out) {

	int bit;
	spi_set_state(spi, SS_DUAL_TX);
	for (bit = 7; bit >= 0; bit -= 2) {
		if (out & (1 << (bit - 1))) {
			gpioWrite(spi->pins.d0, 1);
		}
		else {
			gpioWrite(spi->pins.d0, 0);
		}

		if (out & (1 << (bit - 0))) {
			gpioWrite(spi->pins.d1, 1);
		}
		else {
			gpioWrite(spi->pins.d1, 0);
		}
		gpioWrite(spi->pins.clk, 1);
		spiPause(spi);
		gpioWrite(spi->pins.clk, 0);
		spiPause(spi);
	}
}

static void spiQuadTx(struct ff_spi *spi, uint8_t out) {
	int bit;
	spi_set_state(spi, SS_QUAD_TX);
	for (bit = 7; bit >= 0; bit -= 4) {
		if (out & (1 << (bit - 3))) {
			gpioWrite(spi->pins.d0, 1);
		}
		else {
			gpioWrite(spi->pins.d0, 0);
		}

		if (out & (1 << (bit - 2))) {
			gpioWrite(spi->pins.d1, 1);
		}
		else {
			gpioWrite(spi->pins.d1, 0);
		}

		if (out & (1 << (bit - 1))) {
			gpioWrite(spi->pins.d2, 1);
		}
		else {
			gpioWrite(spi->pins.d2, 0);
		}

		if (out & (1 << (bit - 0))) {
			gpioWrite(spi->pins.d3, 1);
		}
		else {
			gpioWrite(spi->pins.d3, 0);
		}
		gpioWrite(spi->pins.clk, 1);
		spiPause(spi);
		gpioWrite(spi->pins.clk, 0);
		spiPause(spi);
	}
}

static uint8_t spiDualRx(struct ff_spi *spi) {
	int bit;
	uint8_t in = 0;

	spi_set_state(spi, SS_QUAD_RX);
	for (bit = 7; bit >= 0; bit -= 2) {
		gpioWrite(spi->pins.clk, 1);
		spiPause(spi);
		in |= ((!!gpioRead(spi->pins.d0)) << (bit - 1));
		in |= ((!!gpioRead(spi->pins.d1)) << (bit - 0));
		gpioWrite(spi->pins.clk, 0);
		spiPause(spi);
	}
	return in;
}

static uint8_t spiQuadRx(struct ff_spi *spi) {
	int bit;
	uint8_t in = 0;

	spi_set_state(spi, SS_QUAD_RX);
	for (bit = 7; bit >= 0; bit -= 4) {
		gpioWrite(spi->pins.clk, 1);
		spiPause(spi);
		in |= ((!!gpioRead(spi->pins.d0)) << (bit - 3));
		in |= ((!!gpioRead(spi->pins.d1)) << (bit - 2));
		in |= ((!!gpioRead(spi->pins.d2)) << (bit - 1));
		in |= ((!!gpioRead(spi->pins.d3)) << (bit - 0));
		gpioWrite(spi->pins.clk, 0);
		spiPause(spi);
	}
	return in;
}

int spiTx(struct ff_spi *spi, uint8_t word) {
	switch (spi->type) {
	case ST_SINGLE:
		spiSingleTx(spi, word);
		break;
	case ST_DUAL:
		spiDualTx(spi, word);
		break;
	case ST_QUAD:
	case ST_QPI:
		spiQuadTx(spi, word);
		break;
	default:
		return -1;
	}
	return 0;
}

uint8_t spiRx(struct ff_spi *spi) {
	switch (spi->type) {
	case ST_SINGLE:
		return spiSingleRx(spi);
	case ST_DUAL:
		return spiDualRx(spi);
	case ST_QUAD:
	case ST_QPI:
		return spiQuadRx(spi);
	default:
		return 0xff;
	}
}

void spiCommand(struct ff_spi *spi, uint8_t cmd) {
	if (spi->type == ST_QPI)
		spiQuadTx(spi, cmd);
	else
		spiSingleTx(spi, cmd);
}

uint8_t spiCommandRx(struct ff_spi *spi) {
	if (spi->type == ST_QPI)
		return spiQuadRx(spi);
	else
		return spiSingleRx(spi);
}

uint8_t spiReadStatus(struct ff_spi *spi, uint8_t sr) {
	uint8_t val = 0xff;
	(void)sr;

#if 0
	switch (sr) {
	case 1:
#endif
		spiBegin(spi);
		spiCommand(spi, 0x05);
		val = spiCommandRx(spi);
		spiEnd(spi);
#if 0
		break;

	case 2:
		spiBegin(spi);
		spiCommand(spi, 0x35);
		val = spiCommandRx(spi);
		spiEnd(spi);
		break;

	case 3:
		spiBegin(spi);
		spiCommand(spi, 0x15);
		val = spiCommandRx(spi);
		spiEnd(spi);
		break;

	default:
		fprintf(stderr, "unrecognized status register: %d\n", sr);
		break;
	}
#endif
	return val;
}

void spiWriteSecurity(struct ff_spi *spi, uint8_t sr, uint8_t security[256]) {

	if (spi->quirks & SQ_SECURITY_NYBBLE_SHIFT)
		sr <<= 4;

	spiBegin(spi);
	spiCommand(spi, 0x06);
	spiEnd(spi);

	// erase the register
	spiBegin(spi);
	spiCommand(spi, 0x44);
	spiCommand(spi, 0x00); // A23-16
	spiCommand(spi, sr);   // A15-8
	spiCommand(spi, 0x00); // A0-7
	spiEnd(spi);

	spi_get_id(spi);
	sleep(1);

	// write enable
	spiBegin(spi);
	spiCommand(spi, 0x06);
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0x42);
	spiCommand(spi, 0x00); // A23-16
	spiCommand(spi, sr);   // A15-8
	spiCommand(spi, 0x00); // A0-7
	int i;
	for (i = 0; i < 256; i++)
		spiCommand(spi, security[i]);
	spiEnd(spi);

	spi_get_id(spi);
}

void spiReadSecurity(struct ff_spi *spi, uint8_t sr, uint8_t security[256]) {
	if (spi->quirks & SQ_SECURITY_NYBBLE_SHIFT)
		sr <<= 4;

	spiBegin(spi);
	spiCommand(spi, 0x48);	// Read security registers
	spiCommand(spi, 0x00);  // A23-16
	spiCommand(spi, sr);    // A15-8
	spiCommand(spi, 0x00);  // A0-7
	int i;
	for (i = 0; i < 256; i++)
		security[i] = spiCommandRx(spi);
	spiEnd(spi);
}

void spiWriteStatus(struct ff_spi *spi, uint8_t sr, uint8_t val) {

	switch (sr) {
	case 1:
		if (!(spi->quirks & SQ_SKIP_SR_WEL)) {
			spiBegin(spi);
			spiCommand(spi, 0x06);
			spiEnd(spi);
		}

		spiBegin(spi);
		spiCommand(spi, 0x50);
		spiEnd(spi);

		spiBegin(spi);
		spiCommand(spi, 0x01);
		spiCommand(spi, val);
		spiEnd(spi);
		break;

	case 2: {
		uint8_t sr1 = 0x00;
		if (spi->quirks & SQ_SR2_FROM_SR1)
			sr1 = spiReadStatus(spi, 1);

		if (!(spi->quirks & SQ_SKIP_SR_WEL)) {
			spiBegin(spi);
			spiCommand(spi, 0x06);
			spiEnd(spi);
		}


		spiBegin(spi);
		spiCommand(spi, 0x50);
		spiEnd(spi);

		spiBegin(spi);
		if (spi->quirks & SQ_SR2_FROM_SR1) {
			spiCommand(spi, 0x01);
			spiCommand(spi, sr1);
			spiCommand(spi, val);
		}
		else {
			spiCommand(spi, 0x31);
			spiCommand(spi, val);
		}
		spiEnd(spi);
		break;
	}

	case 3:
		if (!(spi->quirks & SQ_SKIP_SR_WEL)) {
			spiBegin(spi);
			spiCommand(spi, 0x06);
			spiEnd(spi);
		}


		spiBegin(spi);
		spiCommand(spi, 0x50);
		spiEnd(spi);

		spiBegin(spi);
		spiCommand(spi, 0x11);
		spiCommand(spi, val);
		spiEnd(spi);
		break;

	default:
		fprintf(stderr, "unrecognized status register: %d\n", sr);
		break;
	}
}

#if 0
struct spi_id spiId(struct ff_spi *spi) {
	return spi->id;
}

static void spi_decode_id(struct ff_spi *spi) {
	spi->id.bytes = -1; // unknown

	if (spi->id.manufacturer_id == 0xef) {
		// spi->id.manufacturer = "Winbond";
		if ((spi->id.memory_type == 0x70)
		 && (spi->id.memory_size == 0x18)) {
			// spi->id.model = "W25Q128JV";
			// spi->id.capacity = "128 Mbit";
			spi->id.bytes = 16 * 1024 * 1024;
		}
	}

	if (spi->id.manufacturer_id == 0x1f) {
		// spi->id.manufacturer = "Adesto";
		 if ((spi->id.memory_type == 0x86)
		  && (spi->id.memory_size == 0x01)) {
			// spi->id.model = "AT25SF161";
			// spi->id.capacity = "16 Mbit";
			spi->id.bytes = 1 * 1024 * 1024;
		}
	}
	return;
}
#endif
static void spi_get_id(struct ff_spi *spi) {
	spiBegin(spi);
	spiCommand(spi, 0x90);	// Read manufacturer ID
	spiCommand(spi, 0x00);  // Dummy byte 1
	spiCommand(spi, 0x00);  // Dummy byte 2
	spiCommand(spi, 0x00);  // Dummy byte 3
	spi->id.manufacturer_id = spiCommandRx(spi);
	spi->id.device_id = spiCommandRx(spi);
	spiEnd(spi);
	return;
#if 0
	spiBegin(spi);
	spiCommand(spi, 0x9f);	// Read device id
	spi->id._manufacturer_id = spiCommandRx(spi);
	spi->id.memory_type = spiCommandRx(spi);
	spi->id.memory_size = spiCommandRx(spi);
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0xab);	// Read electronic signature
	spiCommand(spi, 0x00);  // Dummy byte 1
	spiCommand(spi, 0x00);  // Dummy byte 2
	spiCommand(spi, 0x00);  // Dummy byte 3
	spi->id.signature = spiCommandRx(spi);
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0x4b);	// Read unique ID
	spiCommand(spi, 0x00);  // Dummy byte 1
	spiCommand(spi, 0x00);  // Dummy byte 2
	spiCommand(spi, 0x00);  // Dummy byte 3
	spiCommand(spi, 0x00);  // Dummy byte 4
	spi->id.serial[0] = spiCommandRx(spi);
	spi->id.serial[1] = spiCommandRx(spi);
	spi->id.serial[2] = spiCommandRx(spi);
	spi->id.serial[3] = spiCommandRx(spi);
	spiEnd(spi);

	spi_decode_id(spi);
	return;
#endif
}

void spiOverrideSize(struct ff_spi *spi, uint32_t size) {
	spi->size_override = size;

	// If size is 0, re-read the capacity
	if (!size)
		spi_decode_id(spi);
	else
		spi->id.bytes = size;
}

int spiSetType(struct ff_spi *spi, enum spi_type type) {

	if (spi->type == type)
		return 0;

#ifndef SPI_ONLY_SINGLE
	switch (type) {

	case ST_SINGLE:
#endif
		if (spi->type == ST_QPI) {
			spiBegin(spi);
			spiCommand(spi, 0xff);	// Exit QPI Mode
			spiEnd(spi);
		}
		spi->type = type;
		spi_set_state(spi, SS_SINGLE);
#ifndef SPI_ONLY_SINGLE
		break;

	case ST_DUAL:
		if (spi->type == ST_QPI) {
			spiBegin(spi);
			spiCommand(spi, 0xff);	// Exit QPI Mode
			spiEnd(spi);
		}
		spi->type = type;
		spi_set_state(spi, SS_DUAL_TX);
		break;

	case ST_QUAD:
		if (spi->type == ST_QPI) {
			spiBegin(spi);
			spiCommand(spi, 0xff);	// Exit QPI Mode
			spiEnd(spi);
		}

		// Enable QE bit
		spiWriteStatus(spi, 2, spiReadStatus(spi, 2) | (1 << 1));

		spi->type = type;
		spi_set_state(spi, SS_QUAD_TX);
		break;

	case ST_QPI:
		// Enable QE bit
		spiWriteStatus(spi, 2, spiReadStatus(spi, 2) | (1 << 1));

		spiBegin(spi);
		spiCommand(spi, 0x38);		// Enter QPI Mode
		spiEnd(spi);
		spi->type = type;
		spi_set_state(spi, SS_QUAD_TX);
		break;

	default:
		fprintf(stderr, "Unrecognized SPI type: %d\n", type);
		return 1;
	}
#endif
	return 0;
}

int spiIsBusy(struct ff_spi *spi) {
  	return spiReadStatus(spi, 1) & (1 << 0);
}

int spiBeginErase32(struct ff_spi *spi, uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin(spi);
	spiCommand(spi, 0x06);
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0x52);
	spiCommand(spi, erase_addr >> 16);
	spiCommand(spi, erase_addr >> 8);
	spiCommand(spi, erase_addr >> 0);
	spiEnd(spi);
	return 0;
}

int spiBeginErase64(struct ff_spi *spi, uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin(spi);
	spiCommand(spi, 0x06);
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0xD8);
	spiCommand(spi, erase_addr >> 16);
	spiCommand(spi, erase_addr >> 8);
	spiCommand(spi, erase_addr >> 0);
	spiEnd(spi);
	return 0;
}

int spiBeginWrite(struct ff_spi *spi, uint32_t addr, const void *v_data, unsigned int count) {
	const uint8_t write_cmd = 0x02;
	const uint8_t *data = v_data;
	unsigned int i;

	// Enable Write-Enable Latch (WEL)
	spiBegin(spi);
	spiCommand(spi, 0x06);
	spiEnd(spi);

	// uint8_t sr1 = spiReadStatus(spi, 1);
	// if (!(sr1 & (1 << 1)))
	// 	fprintf(stderr, "error: write-enable latch (WEL) not set, write will probably fail\n");

	spiBegin(spi);
	spiCommand(spi, write_cmd);
	spiCommand(spi, addr >> 16);
	spiCommand(spi, addr >> 8);
	spiCommand(spi, addr >> 0);
	for (i = 0; (i < count) && (i < 256); i++)
		spiTx(spi, *data++);
	spiEnd(spi);

	return 0;
}

uint8_t spiReset(struct ff_spi *spi) {
	// XXX You should check the "Ready" bit before doing this!

	// Shift to QPI mode, then back to Single mode, to ensure
	// we're actually in Single mode.
	spiSetType(spi, ST_QPI);
	spiSetType(spi, ST_SINGLE);

	spiBegin(spi);
	spiCommand(spi, 0x66); // "Enable Reset" command
	spiEnd(spi);

	spiBegin(spi);
	spiCommand(spi, 0x99); // "Reset Device" command
	spiEnd(spi);

	// msleep(30);

	spiBegin(spi);
	spiCommand(spi, 0xab); // "Resume from Deep Power-Down" command
	spiEnd(spi);

	return 0;
}

int spiInit(struct ff_spi *spi) {
	spi->state = SS_UNCONFIGURED;
	spi->type = ST_UNCONFIGURED;

	// Disable memory-mapped mode and enable bit-bang mode
	picorvspi_cfg4_write(0);

	// Reset the SPI flash, which will return it to SPI mode even
	// if it's in QPI mode.
	spiReset(spi);

	spiSetType(spi, ST_SINGLE);

	// Have the SPI flash pay attention to us
	gpioWrite(spi->pins.hold, 1);

	// Disable WP
	gpioWrite(spi->pins.wp, 1);

	gpioSetMode(spi->pins.clk, PI_OUTPUT); // CLK
	gpioSetMode(spi->pins.cs, PI_OUTPUT); // CE0#
	gpioSetMode(spi->pins.mosi, PI_OUTPUT); // MOSI
	gpioSetMode(spi->pins.miso, PI_INPUT); // MISO
	gpioSetMode(spi->pins.hold, PI_OUTPUT);
	gpioSetMode(spi->pins.wp, PI_OUTPUT);

	spi_get_id(spi);

	spi->quirks |= SQ_SR2_FROM_SR1;
	if (spi->id.manufacturer_id == 0xef)
		spi->quirks |= SQ_SKIP_SR_WEL | SQ_SECURITY_NYBBLE_SHIFT;

	return 0;
}

struct ff_spi *spiAlloc(void) {
	static struct ff_spi spi;
	return &spi;
}

void spiSetPin(struct ff_spi *spi, enum spi_pin pin, int val) {
	switch (pin) {
	case SP_MOSI: spi->pins.mosi = val; break;
	case SP_MISO: spi->pins.miso = val; break;
	case SP_HOLD: spi->pins.hold = val; break;
	case SP_WP: spi->pins.wp = val; break;
	case SP_CS: spi->pins.cs = val; break;
	case SP_CLK: spi->pins.clk = val; break;
	case SP_D0: spi->pins.d0 = val; break;
	case SP_D1: spi->pins.d1 = val; break;
	case SP_D2: spi->pins.d2 = val; break;
	case SP_D3: spi->pins.d3 = val; break;
	default: fprintf(stderr, "unrecognized pin: %d\n", pin); break;
	}
}

void spiHold(struct ff_spi *spi) {
	spiBegin(spi);
	spiCommand(spi, 0xb9);
	spiEnd(spi);
}
void spiUnhold(struct ff_spi *spi) {
	spiBegin(spi);
	spiCommand(spi, 0xab);
	spiEnd(spi);
}

void spiFree(void) {
	// Re-enable memory-mapped mode
	picorvspi_cfg4_write(0x80);
}
