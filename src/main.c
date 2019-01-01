#include <stdio.h>
#include <irq.h>
#include <printf.h>
#include <uart.h>
#include <usb.h>

#include <generated/csr.h>

void isr(void) {
    unsigned int irqs;
    
    irqs = irq_pending() & irq_getmask();
    
    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();

    if (irqs & (1 << UART_INTERRUPT))
        uart_isr();
}

static void rv_putchar(void *ignored, char c) {
    (void)ignored;
    uart_write(c);
}

static void init(void) {
    irq_setmask(0);
    irq_setie(1);
    uart_init();
    init_printf(NULL, rv_putchar);
}

int main(int argc, char **argv) {
    (void)argc;
    (void)argv;

    init();

    int i = 0;
    printf("Hello, world!\n");
    while (1) {
        printf("10 PRINT HELLO, WORLD\n");
        printf("20 GOTO 10\n");
        printf("i: %d\n", i++);
    }
    return 0;
}