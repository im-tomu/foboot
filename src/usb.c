#include <grainuum.h>
#include <usb.h>
#include <generated/csr.h>

static struct GrainuumConfig cfg;
static struct GrainuumUSB usb;
static uint8_t usb_buf[67];

void usb_isr(void) {
    grainuumCaptureI(&usb, usb_buf);
    return;
}

void usb_init(void) {
    grainuumInit(&usb, &cfg);
    return;
}

void usbPhyWriteI(const struct GrainuumUSB *usb, const void *buffer, uint32_t size) {
    (void)usb;
    const uint8_t *ubuffer = (const uint8_t *)buffer;
    uint32_t i = 0;
    while (i < size)
        usb_obuf_head_write(ubuffer[i]);
}

int usbPhyReadI(const struct GrainuumUSB *usb, uint8_t *samples) {
    (void)usb;
    int count = 0;
    while (!usb_ibuf_empty_read()) {
        samples[count++] = usb_ibuf_head_read();
    }
    return count;
}