#include <stdio.h>
#include <irq.h>
#include <printf.h>
#include <uart.h>
#include <usb.h>
#include <time.h>

#include "spi.h"
#include <generated/csr.h>

struct ff_spi *spi;

void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();

    if (irqs & (1 << UART_INTERRUPT))
        uart_isr();
}

static void rv_putchar(void *ignored, char c)
{
    (void)ignored;
    if (c == '\n')
        uart_write('\r');
    if (c == '\r')
        return;
    uart_write(c);
}

static void init(void)
{
    init_printf(NULL, rv_putchar);
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    usb_init();
    dfu_init();
    time_init();

    spi = spiAlloc();
    spiSetPin(spi, SP_MOSI, 0);
    spiSetPin(spi, SP_MISO, 1);
    spiSetPin(spi, SP_WP, 2);
    spiSetPin(spi, SP_HOLD, 3);
    spiSetPin(spi, SP_CLK, 4);
    spiSetPin(spi, SP_CS, 5);
    spiSetPin(spi, SP_D0, 0);
    spiSetPin(spi, SP_D1, 1);
    spiSetPin(spi, SP_D2, 2);
    spiSetPin(spi, SP_D3, 3);
    spiInit(spi);
}

#if 0
static const char *usb_hw_api(void) {
#ifdef CSR_USB_EP_0_OUT_EV_PENDING_ADDR
    return "epfifo";
#else
#ifdef CSR_USB_OBUF_EMPTY_ADDR
    return "rawfifo";
#else
#ifdef CSR_USB_WHATEVER
    return "whatever";
#else
    return "unrecognized hw api";
#endif /* CSR_USB_WHATEVER */
#endif /* CSR_USB_OBUF_EMPTY_ADDR */
#endif /* CSR_USB_EP_0_OUT_EV_PENDING_ADDR */
}
#endif

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    init();

    // // picospi_cfg_write(0);
    // picospi_oe_write(0xff);
    // picospi_do_write(0);
    // // uint8_t last_value = 0;
    // printf("\nToggling: %02x  ", picospi_oe_read());
    // while (1) {
    //     // uint8_t new_value = picospi_di_read();
    //     // if (new_value != last_value) {
    //     //     printf("SPI %02x -> %02x\n", last_value, new_value);
    //     //     last_value = new_value;
    //     // }
    //     // picospi_oe_write(0xff);
    //     // printf("\b0");
    //     // picospi_oe_write(0x00);
    //     // printf("\b1");

    //     // picospi_do_write(0x00);
    //     // printf("\b0");
    //     // picospi_do_write(0xff);
    //     // printf("\b1");
    // }
    // printf("\nPress any key to read...");
    // while(1) {
    //     uart_read();
    //     struct spi_id id = spiId(spi);
    //     printf("Manufacturer ID: %s (%02x)\n", id.manufacturer, id.manufacturer_id);
    //     if (id.manufacturer_id != id._manufacturer_id)
    //         printf("!! JEDEC Manufacturer ID: %02x\n",
    //         id._manufacturer_id);
    //     printf("Memory model: %s (%02x)\n", id.model, id.memory_type);
    //     printf("Memory size: %s (%02x)\n", id.capacity, id.memory_size);
    //     printf("Device ID: %02x\n", id.device_id);
    //     if (id.device_id != id.signature)
    //         printf("!! Electronic Signature: %02x\n", id.signature);
    //     printf("Serial number: %02x %02x %02x %02x\n", id.serial[0], id.serial[1], id.serial[2], id.serial[3]);
    //     printf("Status 1: %02x\n", spiReadStatus(spi, 1));
    //     printf("Status 2: %02x\n", spiReadStatus(spi, 2));
    //     printf("Status 3: %02x\n", spiReadStatus(spi, 3));
    // }
    // puts("\nPress any key to start...");
    // uart_read();

    // printf("\n\nUSB API: %s\n", usb_hw_api());
    // puts("Enabling USB");
    usb_connect();
    // printf("USB enabled.\n");
    // usb_print_status();
    int last = 0;
    while (1)
    {
        // if (usb_irq_happened() != last) {
        //     last = usb_irq_happened();
        //     // printf("USB %d IRQ happened\n", last);
        // }
        usb_poll();
        /*
        printf("Press any key to send...  ");
        uart_read();
        printf("Sending...  ");
        bfr[0] = 0;
        bfr[1] = ~0;
        bfr[2] = 0;
        usb_send(NULL, 0, bfr, 1);
        printf("Sent\n");
        */
    }
    return 0;
}