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

static uint32_t do_mirror;

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

static void gpio_write(enum pin pin, int val);

static void gpio_direction(int is_input) {
#if defined(CSR_LXSPI_BASE)
	if (is_input == ((do_mirror >> PIN_MISO_EN) & 1))
		return;
	gpio_write(PIN_MISO_EN, is_input);
#else
	(void)is_input;
#endif
}

static void gpio_write(enum pin pin, int val) {
    if (val)
        do_mirror |= 1 << pin;
    else
        do_mirror &= ~(1 << pin);
#if defined(CSR_PICORVSPI_BASE)
    picorvspi_cfg1_write(do_mirror);
#endif
#if defined(CSR_LXSPI_BASE)
	lxspi_bitbang_write(do_mirror);
#endif
}

static int gpio_read(int pin) {
#if defined(CSR_PICORVSPI_BASE)
    return !!(picorvspi_stat1_read() & (1 << pin));
#endif
#if defined(CSR_LXSPI_BASE)
	(void)pin;
	return lxspi_miso_read();
#endif
}

void spiBegin(void) {
	lxspi_bitbang_write((0 << PIN_MISO_EN) | (0 << PIN_CLK) | (0 << PIN_CS));
}

void spiEnd(void) {
	lxspi_bitbang_write(1 << PIN_CS);
}

static void spiSingleTx(uint8_t out) {
	int bit;

	for (bit = 7; bit >= 0; bit--) {
		if (out & (1 << bit)) {
			lxspi_bitbang_write((0 << PIN_CLK) | (1 << PIN_MOSI));
			lxspi_bitbang_write((1 << PIN_CLK) | (1 << PIN_MOSI));
		} else {
			lxspi_bitbang_write((0 << PIN_CLK) | (0 << PIN_MOSI));
			lxspi_bitbang_write((1 << PIN_CLK) | (0 << PIN_MOSI));
		}
	}
}

static uint8_t spiSingleRx(void) {
	int bit = 0;
	uint8_t in = 0;

	lxspi_bitbang_write((1 << PIN_MISO_EN) | (0 << PIN_CLK));

	while (bit++ < 8) {
		lxspi_bitbang_write((1 << PIN_MISO_EN) | (1 << PIN_CLK));
		in = (in << 1) | gpio_read(PIN_MISO);
		lxspi_bitbang_write((1 << PIN_MISO_EN) | (0 << PIN_CLK));
	}

	return in;
}

static uint8_t spi_read_status(void) {
	uint8_t val;

	spiBegin();
	spiSingleTx(0x05);
	val = spiSingleRx();
	spiEnd();
	return val;
}

int spiIsBusy(void) {
  	return spi_read_status() & (1 << 0);
}

__attribute__((used))
uint32_t spi_id;

__attribute__((used))
uint32_t spiId(void) {
	uint32_t id = 0;

	spiBegin();
	spiSingleTx(0x90);               // Read manufacturer ID
	spiSingleTx(0x00);               // Dummy byte 1
	spiSingleTx(0x00);               // Dummy byte 2
	spiSingleTx(0x00);               // Dummy byte 3
	id = (id << 8) | spiSingleRx();  // Manufacturer ID
	id = (id << 8) | spiSingleRx();  // Device ID
	spiEnd();

	spiBegin();
	spiSingleTx(0x9f);               // Read device id
	(void)spiSingleRx();             // Manufacturer ID (again)
	id = (id << 8) | spiSingleRx();  // Memory Type
	id = (id << 8) | spiSingleRx();  // Memory Size
	spiEnd();

	spi_id = id;
	return id;
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
	// if it's in QPI mode, and ensure the chip is accepting commands.
	spiReset();

	spiId();

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
