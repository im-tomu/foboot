#include <rgb.h>
#include <generated/csr.h>

enum led_registers {
    LEDDCR0 = 8,
    LEDDBR = 9,
    LEDDONR = 10,
    LEDDOFR = 11,
    LEDDBCRR = 5,
    LEDDBCFR = 6,
    LEDDPWRR = 1,
    LEDDPWRG = 2,
    LEDDPWRB = 3,
};

#define BREATHE_ENABLE (1 << 7)
#define BREATHE_EDGE_ON (0 << 6)
#define BREATHE_EDGE_BOTH (1 << 6)
#define BREATHE_MODE_MODULATE (1 << 5)
#define BREATHE_RATE(x) ((x & 7) << 0)

static void rgb_write(uint8_t value, uint8_t addr) {
    rgb_addr_write(addr);
    rgb_dat_write(value);
}

void rgb_init(void) {
    // Turn on the RGB block and current enable, as well as enabling led control
    rgb_ctrl_write((1 << 0) | (1 << 1) | (1 << 2));

    rgb_write((1 << 7) | (1 << 6), LEDDCR0);

    // Set clock register to 12 MHz / 64 kHz - 1
    rgb_write((12000000/64000)-1, LEDDBR);

    rgb_write(12, LEDDONR);
    rgb_write(24, LEDDOFR);

    rgb_write(BREATHE_ENABLE | BREATHE_EDGE_BOTH
            | BREATHE_MODE_MODULATE | BREATHE_RATE(2), LEDDBCRR);
    rgb_write(BREATHE_ENABLE | BREATHE_MODE_MODULATE | BREATHE_RATE(3), LEDDBCFR);

    rgb_write(0x00/4, LEDDPWRG); // Red
    rgb_write(0x4a/4, LEDDPWRB); // Green
    rgb_write(0xe1/4, LEDDPWRR); // Blue
}