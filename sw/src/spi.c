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

struct spi_id spi_id;

static uint8_t do_mirror;

enum pin {
#if defined(CSR_PICORVSPI_BASE)
	PIN_MOSI = 0,
	PIN_MISO = 1,
	PIN_WP = 2,
	PIN_HOLD = 3,
	PIN_CLK = 4,
	PIN_CS = 5,
#endif
#if defined(CSR_LXSPI_BASE)
	PIN_MOSI = 0,
	PIN_CLK = 1,
	PIN_CS = 2,
	PIN_MISO_EN = 3,
	PIN_MISO = 4, // Value is ignored
#endif
};

static void gpioWrite(enum pin pin, int val);

static void gpioDirection(int is_input) {
#if defined(CSR_LXSPI_BASE)
	if (is_input == ((do_mirror >> PIN_MISO_EN) & 1))
		return;
	gpioWrite(PIN_MISO_EN, is_input);
#else
	(void)is_input;
#endif
}

static void gpioWrite(enum pin pin, int val) {
    if (val)
        do_mirror |= 1 << pin;
    else
        do_mirror &= ~(1 << pin);
#if defined(CSR_PICORVSPI_BASE)
    picorvspi_cfg1_write(do_mirror);
#endif
#if defined(CSR_LXSPI_BASE)
	if (pin == PIN_MOSI)
		gpioDirection(1);
	lxspi_bitbang_write(do_mirror);
#endif
}

static int gpioRead(int pin) {
#if defined(CSR_PICORVSPI_BASE)
    return !!(picorvspi_stat1_read() & (1 << pin));
#endif
#if defined(CSR_LXSPI_BASE)
	if (pin == PIN_MISO)
		gpioDirection(1);
	return lxspi_miso_read();
#endif
}

static void gpioSync(void) {
}

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
};

static void spi_get_id(void);

void spiPause(void) {
	gpioSync();
	return;
}

void spiBegin(void) {
	gpioWrite(PIN_CS, 0);
}

void spiEnd(void) {
	gpioWrite(PIN_CS, 1);
}

static uint8_t spiXfer(uint8_t out) {
	int bit;
	uint8_t in = 0;

	for (bit = 7; bit >= 0; bit--) {
		if (out & (1 << bit)) {
			gpioWrite(PIN_MOSI, 1);
		}
		else {
			gpioWrite(PIN_MOSI, 0);
		}
		gpioWrite(PIN_CLK, 1);
		spiPause();
		in |= ((!!gpioRead(PIN_MISO)) << bit);
		gpioWrite(PIN_CLK, 0);
		spiPause();
	}

	return in;
}

static void spiSingleTx(uint8_t out) {
	spiXfer(out);
}

static uint8_t spiSingleRx(void) {
	return spiXfer(0xff);
}

uint8_t spiReadStatus(uint8_t sr) {
	uint8_t val = 0xff;
	(void)sr;

	spiBegin();
	spiSingleTx(0x05);
	val = spiSingleRx();
	spiEnd();
	return val;
}

static void spi_get_id(void) {
	spiBegin();
	spiSingleTx(0x90);	// Read manufacturer ID
	spiSingleTx(0x00);  // Dummy byte 1
	spiSingleTx(0x00);  // Dummy byte 2
	spiSingleTx(0x00);  // Dummy byte 3
	spi_id.manufacturer_id = spiSingleRx();
	spi_id.device_id = spiSingleRx();
	spiEnd();
	return;
}

int spiIsBusy(void) {
  	return spiReadStatus(1) & (1 << 0);
}

int spiBeginErase4(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiSingleTx(0x06);
	spiEnd();

	spiBegin();
	spiSingleTx(0x20);
	spiSingleTx(erase_addr >> 16);
	spiSingleTx(erase_addr >> 8);
	spiSingleTx(erase_addr >> 0);
	spiEnd();
	return 0;
}

int spiBeginErase32(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiSingleTx(0x06);
	spiEnd();

	spiBegin();
	spiSingleTx(0x52);
	spiSingleTx(erase_addr >> 16);
	spiSingleTx(erase_addr >> 8);
	spiSingleTx(erase_addr >> 0);
	spiEnd();
	return 0;
}

int spiBeginErase64(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiSingleTx(0x06);
	spiEnd();

	spiBegin();
	spiSingleTx(0xD8);
	spiSingleTx(erase_addr >> 16);
	spiSingleTx(erase_addr >> 8);
	spiSingleTx(erase_addr >> 0);
	spiEnd();
	return 0;
}

int spiBeginWrite(uint32_t addr, const void *v_data, unsigned int count) {
	const uint8_t write_cmd = 0x02;
	const uint8_t *data = v_data;
	unsigned int i;

	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiSingleTx(0x06);
	spiEnd();

	spiBegin();
	spiSingleTx(write_cmd);
	spiSingleTx(addr >> 16);
	spiSingleTx(addr >> 8);
	spiSingleTx(addr >> 0);
	for (i = 0; (i < count) && (i < 256); i++)
		spiSingleTx(*data++);
	spiEnd();

	return 0;
}

uint8_t spiReset(void) {
	// Writing 0xff eight times is equivalent to exiting QPI mode,
	// or if CFM mode is enabled it will terminate CFM and return
	// to idle.
	unsigned int i;
	spiBegin();
	for (i = 0; i < 8; i++)
		spiSingleTx(0xff);
	spiEnd();

	// Some SPI parts require this to wake up
	spiBegin();
	spiSingleTx(0xab);	// Read electronic signature
	spiEnd();

	return 0;
}

int spiInit(void) {
	// Disable memory-mapped mode and enable bit-bang mode
#if defined(CSR_PICORVSPI_BASE)
	picorvspi_cfg4_write(0);
#endif
#if defined(CSR_LXSPI_BASE)
	lxspi_bitbang_en_write(1);
#endif

	// Reset the SPI flash, which will return it to SPI mode even
	// if it's in QPI mode.
	spiReset();

	spi_get_id();

	return 0;
}

void spiHold(void) {
	spiBegin();
	spiSingleTx(0xb9);
	spiEnd();

}
void spiUnhold(void) {
	spiBegin();
	spiSingleTx(0xab);
	spiEnd();
}

void spiFree(void) {
	// Re-enable memory-mapped mode
#if defined(CSR_PICORVSPI_BASE)
	picorvspi_cfg4_write(0x80);
#endif
#if defined(CSR_LXSPI_BASE)
	lxspi_bitbang_en_write(0);
#endif
}
