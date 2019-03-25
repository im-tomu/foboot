#ifndef _SPI_GPIO_H
#define _SPI_GPIO_H

#define PI_OUTPUT 1
#define PI_INPUT 0
#define PI_ALT0 PI_INPUT

void gpioSetMode(int pin, int mode);
void gpioWrite(int pin, int val);
int gpioRead(int pin);

#endif