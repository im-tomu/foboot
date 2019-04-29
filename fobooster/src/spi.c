#include <stdint.h>
#include <csr.h>

#define SP_MOSI_PIN 0
#define SP_MISO_PIN 1
#define SP_WP_PIN 2
#define SP_HOLD_PIN 3
#define SP_CLK_PIN 4
#define SP_CS_PIN 5
#define SP_D0_PIN 0
#define SP_D1_PIN 1
#define SP_D2_PIN 2
#define SP_D3_PIN 3

#define PI_OUTPUT 1
#define PI_INPUT 0

// static void gpioSetMode(int pin, int mode) {
//     static uint8_t oe_mirror;
//     if (mode)
//         oe_mirror |= 1 << pin;
//     else
//         oe_mirror &= ~(1 << pin);
//     picorvspi_cfg2_write(oe_mirror);
// }

static void gpioWrite(int pin, int val) {
    static uint8_t do_mirror;
    if (val)
        do_mirror |= 1 << pin;
    else
        do_mirror &= ~(1 << pin);
    picorvspi_cfg1_write(do_mirror);
}

static int gpioRead(int pin) {
    return !!(picorvspi_stat1_read() & (1 << pin));
}

void spiBegin(void) {
    gpioWrite(SP_WP_PIN, 1);
    gpioWrite(SP_HOLD_PIN, 1);
	gpioWrite(SP_CS_PIN, 0);
}

void spiEnd(void) {
	gpioWrite(SP_CS_PIN, 1);
}

void spiPause(void) {
	return;
}

static uint8_t spiXfer(uint8_t out) {
	int bit;
	uint8_t in = 0;

	for (bit = 7; bit >= 0; bit--) {
		if (out & (1 << bit)) {
			gpioWrite(SP_MOSI_PIN, 1);
		}
		else {
			gpioWrite(SP_MOSI_PIN, 0);
		}
		gpioWrite(SP_CLK_PIN, 1);
		spiPause();
		in |= ((!!gpioRead(SP_MISO_PIN)) << bit);
		gpioWrite(SP_CLK_PIN, 0);
		spiPause();
	}

	return in;
}

void spiCommand(uint8_t cmd) {
    spiXfer(cmd);
}

uint8_t spiCommandRx(void) {
    return spiXfer(0xff);
}

uint8_t spiReadStatus(void) {
	uint8_t val = 0xff;
    spiBegin();
    spiCommand(0x05);
    val = spiCommandRx();
    spiEnd();
    return val;
}

void spiBeginErase4(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiCommand(0x06);
	spiEnd();

	spiBegin();
	spiCommand(0x20);
	spiCommand(erase_addr >> 16);
	spiCommand(erase_addr >> 8);
	spiCommand(erase_addr >> 0);
	spiEnd();
}

void spiBeginErase32(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiCommand(0x06);
	spiEnd();

	spiBegin();
	spiCommand(0x52);
	spiCommand(erase_addr >> 16);
	spiCommand(erase_addr >> 8);
	spiCommand(erase_addr >> 0);
	spiEnd();
}

void spiBeginErase64(uint32_t erase_addr) {
	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiCommand(0x06);
	spiEnd();

	spiBegin();
	spiCommand(0xD8);
	spiCommand(erase_addr >> 16);
	spiCommand(erase_addr >> 8);
	spiCommand(erase_addr >> 0);
	spiEnd();
}

int spiIsBusy(void) {
  	return spiReadStatus() & (1 << 0);
}

void spiBeginWrite(uint32_t addr, const void *v_data, unsigned int count) {
	const uint8_t write_cmd = 0x02;
	const uint8_t *data = v_data;
	unsigned int i;

	// Enable Write-Enable Latch (WEL)
	spiBegin();
	spiCommand(0x06);
	spiEnd();

	spiBegin();
	spiCommand(write_cmd);
	spiCommand(addr >> 16);
	spiCommand(addr >> 8);
	spiCommand(addr >> 0);
	for (i = 0; (i < count) && (i < 256); i++)
		spiCommand(*data++);
	spiEnd();
}