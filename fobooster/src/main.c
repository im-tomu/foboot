#include <fobooster.h>
#include <csr.h>
#include <spi.h>

// Defined in the linker
extern struct fobooster_data fobooster_data;
extern const struct fobooster_data fobooster_src;

__attribute__((noreturn)) void reboot(void)
{
    uint8_t image_index = 0;
    reboot_ctrl_write(0xac | (image_index & 3) << 0);
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

uint32_t bytes_left;
uint32_t target_addr;
uint32_t *current_ptr;
uint32_t page_offset;

// Erase the Toboot configuration, which will prevent us from
// overwriting Toboot again.
// Run this from RAM to ensure we don't hardfault.
// Reboot after we're done.
__attribute__((noreturn)) static void finish_flashing(void)
{
#if 0
    uint32_t vector_addr = (uint32_t)&toboot_configuration;

    // Jump back into the bootloader when we reboot
    toboot_runtime.magic = TOBOOT_FORCE_ENTRY_MAGIC;

    while (MSC->STATUS & MSC_STATUS_BUSY)
        ;

    MSC->WRITECTRL |= MSC_WRITECTRL_WREN;
    MSC->ADDRB = vector_addr;
    MSC->WRITECMD = MSC_WRITECMD_LADDRIM;
    MSC->WRITECMD = MSC_WRITECMD_ERASEPAGE;

    while (MSC->STATUS & MSC_STATUS_BUSY)
        ;
#endif
    reboot();
}

void isr(void)
{
    /* unused */
}

__attribute__((noreturn)) void fobooster_main(void)
{
    // If the booster data is too big, just let the watchdog timer reboot us,
    // since the program is invalid.
    if (fobooster_src.payload_size != 104090)
    {
        reboot();
    }

    // We want to run entirely from RAM, so copy the booster payload to RAM too.
    memcpy((void *restrict) & fobooster_src, &fobooster_data, fobooster_src.payload_size);

    // Ensure the hash matches what's expected.
    if (XXH32(fobooster_data.payload, fobooster_data.payload_size, FOBOOSTER_SEED) != fobooster_data.xxhash)
    {
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
             bytes_left && page_offset < SPI_ERASE_SECTOR_SIZE;
             page_offset += SPI_PROGRAM_PAGE_SIZE)
        {
            uint32_t bytes_to_write = bytes_left;
            if (bytes_to_write > SPI_PROGRAM_PAGE_SIZE)
                bytes_to_write = SPI_PROGRAM_PAGE_SIZE;
            spiBeginWrite(target_addr, current_ptr, bytes_to_write);
            ftfl_busy_wait();
            current_ptr += SPI_PROGRAM_PAGE_SIZE;
            target_addr += SPI_PROGRAM_PAGE_SIZE;
            bytes_left -= bytes_to_write;
        }
    }

    finish_flashing();
}