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

#define PAGE_PROGRAM_CMD 0x02
#define WRDI_CMD         0x04
#define RDSR_CMD         0x05
#define WREN_CMD         0x06
#define SE64_CMD         0xd8

#define SR_WIP              1

#define SPIFLASH_SECTOR_SIZE 	65536
#define SPIFLASH_PAGE_SIZE 		256

#define BITBANG_CLK         (1 << 1)
#define BITBANG_CS_N        (1 << 2)
#define BITBANG_DQ_INPUT    (1 << 3)

static void flash_write_addr(unsigned int addr);
static uint8_t flash_read_byte(void);
static void flash_write_byte(unsigned char b);

static uint32_t spi_id;

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

static uint32_t spi_get_id(void);

void spi_pause(void)
{
	return;
}

void spi_begin(void)
{
	litexspi_bitbang_write(0);  // ~CS_N ~CLK
    litexspi_bitbang_en_write(1);
}

void spi_end(void)
{
	litexspi_bitbang_write(0);  // ~CS_N ~CLK
	litexspi_bitbang_write(BITBANG_CS_N);
    litexspi_bitbang_en_write(0);
}

uint8_t spi_read_status(uint8_t sr)
{
	uint8_t val = 0xff;
	(void)sr;

	spi_begin();
	flash_write_byte(0x05);
	val = flash_read_byte();
	spi_end();

	return val;
}

static uint32_t spi_get_id(void)
{
	uint32_t id = 0;

	spi_begin();
	flash_write_byte(0x90);	// Read manufacturer ID
	flash_write_addr(0);	// Dummy bytes
	id = (id << 8) | flash_read_byte(); // Manufacturer ID
	id = (id << 8) | flash_read_byte(); // Device ID
	spi_end();

	spi_begin();
	flash_write_byte(0x9f); // Read device ID
	(void)flash_read_byte(); // Manufacturer ID (again)
	id = (id << 8) | flash_read_byte(); // Memory type
	id = (id << 8) | flash_read_byte(); // Memory size
	spi_end();

	return id;
}

static uint8_t flash_read_byte(void)
{
    unsigned char sr;
    unsigned char i;

	sr = 0;
	litexspi_bitbang_write(BITBANG_DQ_INPUT);
	for(i = 0; i < 8; i++) {
		sr <<= 1;
		litexspi_bitbang_write(BITBANG_CLK | BITBANG_DQ_INPUT);
		sr |= litexspi_miso_read();
		litexspi_bitbang_write(0           | BITBANG_DQ_INPUT);
	}

	return sr;
}

static void flash_write_byte(unsigned char b)
{
    int i;
    litexspi_bitbang_write(0); // ~CS_N ~CLK

    for(i = 0; i < 8; i++, b <<= 1) {

        litexspi_bitbang_write((b & 0x80) >> 7);
        litexspi_bitbang_write(((b & 0x80) >> 7) | BITBANG_CLK);
    }

    litexspi_bitbang_write(0); // ~CS_N ~CLK

}

static void flash_write_addr(unsigned int addr)
{
    int i;
    litexspi_bitbang_write(0);

    for(i = 0; i < 24; i++, addr <<= 1) {
        litexspi_bitbang_write((addr & 0x800000) >> 23);
        litexspi_bitbang_write(((addr & 0x800000) >> 23) | BITBANG_CLK);
    }

    litexspi_bitbang_write(0);
}

static void wait_for_device_ready(void)
{
    unsigned char sr;
    unsigned char i;
    do {
        sr = 0;
        flash_write_byte(RDSR_CMD);
        litexspi_bitbang_write(BITBANG_DQ_INPUT);
        for(i = 0; i < 8; i++) {
            sr <<= 1;
            litexspi_bitbang_write(BITBANG_CLK | BITBANG_DQ_INPUT);
            sr |= litexspi_miso_read();
            litexspi_bitbang_write(0           | BITBANG_DQ_INPUT);
        }
        litexspi_bitbang_write(0);
        litexspi_bitbang_write(BITBANG_CS_N);
    } while(sr & SR_WIP);
}

void erase_flash_sector(unsigned int addr)
{
    unsigned int sector_addr = addr & ~(SPIFLASH_SECTOR_SIZE - 1);

    litexspi_bitbang_en_write(1);

    wait_for_device_ready();

    flash_write_byte(WREN_CMD);
    litexspi_bitbang_write(BITBANG_CS_N);

    flash_write_byte(SE64_CMD);
    flash_write_addr(sector_addr);
    litexspi_bitbang_write(BITBANG_CS_N);

    wait_for_device_ready();

    litexspi_bitbang_en_write(0);
}

void write_to_flash_page(unsigned int addr, const unsigned char *c, unsigned int len)
{
    unsigned int i;

    if(len > SPIFLASH_PAGE_SIZE)
        len = SPIFLASH_PAGE_SIZE;

    litexspi_bitbang_en_write(1);

    wait_for_device_ready();

    flash_write_byte(WREN_CMD);
    litexspi_bitbang_write(BITBANG_CS_N);
    flash_write_byte(PAGE_PROGRAM_CMD);
    flash_write_addr((unsigned int)addr);
    for(i = 0; i < len; i++)
        flash_write_byte(*c++);

    litexspi_bitbang_write(BITBANG_CS_N);
    litexspi_bitbang_write(0);

    wait_for_device_ready();

    litexspi_bitbang_en_write(0);
}

uint8_t spi_reset(void) {
	spi_begin();
	flash_write_byte(0x66); // "Enable Reset" command
	spi_end();

	spi_begin();
	flash_write_byte(0x99); // "Reset Device" command
	spi_end();

	spi_begin();
	flash_write_byte(0xab); // "Resume from Deep Power-Down" command
	spi_end();

	return 0;
}

int spi_init(void) {
	// Reset the SPI flash, which will return it to SPI mode even
	// if it's in QPI mode.
	spi_reset();

	spi_id = spi_get_id();
	if (spi_id ==  0xc2152815) {
		uint8_t spi_status = spi_read_status(0);
		// Enable QE bit if necessary
		if (! (spi_status & (1 << 6))) {
			spi_status |= (1 << 6);
			spi_begin();
			flash_write_byte(0x01);
			flash_write_byte(spi_status);
			spi_end();
		}
	}

	// spi_quirks |= SQ_SR2_FROM_SR1;
	// if (spi->id.manufacturer_id == 0xef)
	// 	spi->quirks |= SQ_SKIP_SR_WEL | SQ_SECURITY_NYBBLE_SHIFT;

	return 0;
}

void spi_hold(void) {
	spi_begin();
	flash_write_byte(0xb9);
	spi_end();
}

void spi_unhold(void) {
	spi_begin();
	flash_write_byte(0xab);
	spi_end();
}

void spi_free(void) {
	// Re-enable memory-mapped mode
	// litexspi_bitbang_en_write(0);
}
