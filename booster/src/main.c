#include <booster.h>
#include <csr.h>
#include <irq.h>
#include <rgb.h>
#include <spi.h>
#include <usb.h>

extern uint32_t booster_signature;
extern uint32_t booster_length;
extern uint32_t booster_checksum;
extern uint32_t image_length;
extern uint32_t hash_length;
extern uint32_t image_seed;
extern uint32_t spi_id;

extern struct booster_data booster_src;
uint32_t read_spi_id;
uint32_t cached_image_length;
uint32_t cached_spi_id;

// Note: This multiboot reference has the initial image
// booting to offset 0x40000, which is where the recovery
// image will be.
// We patch the target image when we generate the install
// image, so this is as designed.
static uint8_t multiboot_reference[] = {
    0x7e, 0xaa, 0x99, 0x7e, 0x92, 0x00, 0x00, 0x44,
    0x03, 0x04 /* SEE ABOVE */, 0x00, 0xa0, 0x82, 0x00, 0x00, 0x01,
    0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

    0x7e, 0xaa, 0x99, 0x7e, 0x92, 0x00, 0x00, 0x44,
    0x03, 0x00, 0x00, 0xa0, 0x82, 0x00, 0x00, 0x01,
    0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

static void spi_bb_enable(void) {
    lxspi_bitbang_en_write(1);
}

static void spi_bb_disable(void) {
    lxspi_bitbang_en_write(0);
}

static uint32_t cached_image[0x1a000/4];

void msleep(int ms)
{
    timer0_en_write(0);
    timer0_reload_write(0);
    timer0_load_write(CONFIG_CLOCK_FREQUENCY/1000*ms);
    timer0_en_write(1);
    timer0_update_value_write(1);
    while(timer0_value_read())
        timer0_update_value_write(1);
}

__attribute__((noreturn)) void reboot(void)
{
    uint8_t image_index = 2;
    reboot_ctrl_write(0xac | (image_index & 3) << 0);
    while (1)
        ;
    __builtin_unreachable();
}

// Returns whether the flash controller is busy
static bool ftfl_busy()
{
    return spiIsBusy();
}

// Wait for the flash memory controller to finish any pending operation.
static void ftfl_busy_wait()
{
    while (ftfl_busy())
        ;
}

// Erase the sector that contains the specified address.
static void ftfl_begin_erase_sector(uint32_t address)
{
    ftfl_busy_wait();
    spiBeginErase4(address);
}

/// Erase Booster from flash, and retarget 
static void erase_booster(void)
{
    spi_bb_enable();
    ftfl_busy_wait();

    // On reboot, go back to the primary bootloader
    uint8_t zero = 0;
    spiBeginWrite(9, &zero, 1);
    ftfl_busy_wait();

    // // Erase our bitstream (but not really)
    // !!! Don't erase our bitstream, since we don't have the
    // !!! ability to dynamically update SB_WARMBOOT.
    // !!! Instead, we'll actually reboot into the image located
    // !!! at offset 0x40000, but without Booster present.  This
    // !!! will be functionally identical to booting to the image
    // !!! at offset 0x00000, since it was simply copied from here.
    // ftfl_begin_erase_sector(0x40000);
    // ftfl_busy_wait();

    // Erase Booster
    ftfl_begin_erase_sector(0x5a000);
}

__attribute__((noreturn)) static void finish_flashing(void)
{
    erase_booster();
    ftfl_busy_wait();
    reboot();
}

enum error_code {
    NO_ERROR = 0,
    INVALID_IMAGE_SIZE = 1,
    HASH_MISMATCH = 2,
    SPI_MISMATCH = 3,
    MISSING_MULTIBOOT = 4,
    FINAL_IMAGE_MISMATCH_END = 5,
};

__attribute__((used))
volatile enum error_code error_code;

__attribute__((noreturn)) static void error(enum error_code code)
{
    error_code = code;
    rgb_mode_error();
    erase_booster();
    ftfl_busy_wait();

    while(1);
}

void isr(void)
{
    unsigned int irqs;

    irqs = irq_pending() & irq_getmask();

    if (irqs & (1 << USB_INTERRUPT))
        usb_isr();
}

uint32_t calculated_hash;
__attribute__((noreturn)) void fobooster_main(void)
{
    uint32_t bytes_left;
    uint32_t target_addr;
    const uint8_t *current_ptr;
    uint32_t page_offset;
    uint32_t i;

    irq_setmask(0);
    irq_setie(1);

    rgb_init();
    usb_init();
    usb_connect();
    spi_bb_disable();

    // If the booster data doesn't fit in our cached image, error out.
    if (image_length > sizeof(cached_image))
    {
        error(INVALID_IMAGE_SIZE);
    }

    // Patch the target image so that it goes to our program if the user
    // reboots during an update.
    ((uint8_t *)cached_image)[9] = 0x04;

    // Ensure the hash matches what's expected.  Note that the hash includes the patch
    // that's made in the previous line.
    calculated_hash = XXH32((const void *)0x20040000, hash_length, image_seed);
    if (calculated_hash != booster_src.xxhash)
    {
        error(HASH_MISMATCH);
    }

    // We want to run entirely from RAM, so copy the booster payload to RAM too.
    memcpy(cached_image, (const void *)0x20040000, image_length);

    // Ensure the multiboot at least looks sane
    for (target_addr = 0; target_addr < sizeof(multiboot_reference); target_addr++)
    {
        if (((uint8_t *)cached_image)[target_addr] != multiboot_reference[target_addr])
        {
            error(MISSING_MULTIBOOT);
        }
    }

    // Now that everything is copied to RAM, disable memory-mapped SPI mode.
    // This puts the SPI into bit-banged mode, which allows us to write to it.
    cached_spi_id = spi_id; // Copy spi_id over first, since it is still on the flash.
    cached_image_length = image_length;

    spi_bb_enable();
    ftfl_busy_wait();

    read_spi_id = spiId();
    // PVT has two possible SPI flashes, so treat them
    // the same as the "PVT" SPI ID.
    if (read_spi_id == 0xc8144015) {
        read_spi_id = 0xc2152815;
    }
    if (cached_spi_id == 0xc8144015) {
        cached_spi_id = 0xc2152815;
    }
    if (cached_spi_id != read_spi_id) {
        error(SPI_MISMATCH);
    }

    bytes_left = cached_image_length;
    target_addr = 0;
    current_ptr = (const uint8_t *)&cached_image[0];

    uint32_t check_block[SPI_ERASE_SECTOR_SIZE/sizeof(uint32_t)];

    uint8_t rgb_color = 80;
    while (bytes_left && (target_addr < 131072))
    {
        // Check to see if the sector has changed -- don't do anything if it hasn't.
        spi_bb_disable();
        memcpy(check_block, (void *)(target_addr + 0x20000000), SPI_ERASE_SECTOR_SIZE);
        spi_bb_enable();
        if (!memcmp(check_block, current_ptr, SPI_ERASE_SECTOR_SIZE)) {
            current_ptr += SPI_ERASE_SECTOR_SIZE;
            target_addr += SPI_ERASE_SECTOR_SIZE;
            bytes_left  -= SPI_ERASE_SECTOR_SIZE;
            continue;
        }

        // Erase one 4096-byte block
        ftfl_begin_erase_sector(target_addr);

        // Program each 256-byte page
        for (page_offset = 0;
             bytes_left && (page_offset < SPI_ERASE_SECTOR_SIZE);
             page_offset += SPI_PROGRAM_PAGE_SIZE)
        {
            rgb_wheel(rgb_color+=10);
            uint32_t bytes_to_write = bytes_left;
            if (bytes_to_write > SPI_PROGRAM_PAGE_SIZE)
                bytes_to_write = SPI_PROGRAM_PAGE_SIZE;
            ftfl_busy_wait();
            spiBeginWrite(target_addr, current_ptr, bytes_to_write);
            current_ptr += SPI_PROGRAM_PAGE_SIZE;
            target_addr += SPI_PROGRAM_PAGE_SIZE;
            bytes_left -= bytes_to_write;
        }
    }

    // Final check to ensure the target image matches our image
    spi_bb_disable();
    // Pre-cache due to latency bug when switching between bit-bang and normal mode
    for (i = 0; i < cached_image_length; i += 4) {
        uint32_t dummy;
        memcpy(&dummy, (void *)(0x20000000 + i), 4);
    }
    if (memcmp((const void *)0x20000000, cached_image, cached_image_length)) {
        error(FINAL_IMAGE_MISMATCH_END);
    }
    spi_bb_enable();

    rgb_mode_writing();
    finish_flashing();
}
