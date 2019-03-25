#include <stdio.h>
#include <generated/csr.h>

#include "spi-gpio.h"

static uint8_t do_mirror;
static uint8_t oe_mirror;

void gpioSetMode(int pin, int mode) {
    if (mode)
        oe_mirror |= 1 << pin;
    else
        oe_mirror &= ~(1 << pin);
    picospi_oe_write(oe_mirror);
}

void gpioWrite(int pin, int val) {
    if (val)
        do_mirror |= 1 << pin;
    else
        do_mirror &= ~(1 << pin);
    picospi_do_write(do_mirror);
}

int gpioRead(int pin) {
    return !!(picospi_di_read() & (1 << pin));
}