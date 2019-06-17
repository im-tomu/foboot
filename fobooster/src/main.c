#include <fobooster.h>
#include <csr.h>
#include <spi.h>
#include <rgb.h>

// Defined in the linker
extern struct fobooster_data fobooster_data;
extern const struct fobooster_data fobooster_src;

void msleep(int ms)
{
    timer0_en_write(0);
    timer0_reload_write(0);
    timer0_load_write(SYSTEM_CLOCK_FREQUENCY/1000*ms);
    timer0_en_write(1);
    timer0_update_value_write(1);
    while(timer0_value_read())
        timer0_update_value_write(1);
}

__attribute__((noreturn)) void reboot(void)
{
    uint8_t image_index = 0;
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

// Erase the Toboot configuration, which will prevent us from
// overwriting Toboot again.
// Run this from RAM to ensure we don't hardfault.
// Reboot after we're done.
__attribute__((noreturn)) static void finish_flashing(void)
{
    ftfl_busy_wait();
    reboot();
}

void isr(void)
{
    /* unused */
}

__attribute__((noreturn)) void fobooster_main(void)
{
    uint32_t bytes_left;
    uint32_t target_addr;
    void *current_ptr;
    uint32_t page_offset;

    rgb_init();

    // If the booster data is not correct, the program is invalid.
    if (fobooster_src.payload_size != 104250)
    {
        rgb_mode_error();
        msleep(1000);
        reboot();
    }

    // We want to run entirely from RAM, so copy the booster payload to RAM too.
    memcpy((void *restrict) &fobooster_data, &fobooster_src, sizeof(struct fobooster_data));
    memcpy((void *restrict) &fobooster_data.payload[0], &fobooster_src.payload[0], fobooster_data.payload_size);

    // Ensure the hash matches what's expected.
    if (XXH32(fobooster_data.payload, fobooster_data.payload_size, FOBOOSTER_SEED) != fobooster_data.xxhash)
    {
        rgb_mode_error();
        msleep(1000);
        msleep(1000);
        msleep(1000);
        msleep(1000);
        msleep(1000);
        reboot();
    }

    // Now that everything is copied to RAM, disable memory-mapped SPI mode.
    // This puts the SPI into bit-banged mode, which allows us to write to it.
    picorvspi_cfg4_write(0);

    bytes_left = fobooster_data.payload_size;
    target_addr = 0;
    current_ptr = &fobooster_data.payload[0];

    while (bytes_left && (target_addr < 131072))
    {
        ftfl_begin_erase_sector(target_addr);

        for (page_offset = 0;
             bytes_left && (page_offset < SPI_ERASE_SECTOR_SIZE);
             page_offset += SPI_PROGRAM_PAGE_SIZE)
        {
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

    rgb_mode_writing();
    msleep(1000);
    finish_flashing();
}