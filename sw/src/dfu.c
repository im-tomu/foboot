/*
 * Fadecandy DFU Bootloader
 * 
 * Copyright (c) 2013 Micah Elizabeth Scott
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <stdbool.h>
#include <string.h>

#include <dfu.h>
#include <rgb.h>
#include <generated/mem.h>
#include <generated/csr.h>

#ifndef CONFIG_RESCUE_IMAGE_OFFSET
#  define CONFIG_RESCUE_IMAGE_OFFSET 262144
#endif
#define RAM_BOOT_SENTINAL 0x17ab0f23

#define ERASE_SIZE 4096 // Erase block size (in bytes)
#define WRITE_SIZE 256 // Number of bytes we can write

#define FLASH_MAX_ADDR ((1024 * 1024) + (1024 * 512)) // 1.5 MB max

#include <spi.h>

// Internal flash-programming state machine
static unsigned fl_current_addr = 0;
static enum {
    flsIDLE = 0,
    flsERASING,
    flsPROGRAMMING
} fl_state;

#define BUSY_POLL_TIMEOUT_MS 5
#define MANIFEST_POLL_TIMEOUT_MS 1
#define MANIFEST_TIMEOUT_MS 10
#define IDLE_TIMEOUT_MS 5

static dfu_state_t dfu_state = dfuIDLE;
static dfu_status_t dfu_status = OK;
static unsigned dfu_poll_timeout_ms = IDLE_TIMEOUT_MS;

static uint32_t dfu_buffer[DFU_TRANSFER_SIZE/4];
static uint32_t dfu_buffer_offset;
static uint32_t dfu_bytes_remaining;
static uint32_t ram_mode; // Set this to non-zero to load data into RAM.

// Memory offset we're uploading to.
static uint32_t dfu_target_address;

uint32_t dfu_origin_addr(void) {
    if (ram_mode)
        return ram_mode;
    return CONFIG_RESCUE_IMAGE_OFFSET + SPIFLASH_BASE;
}

static void set_state(dfu_state_t new_state, dfu_status_t new_status) {
    if (new_state == dfuIDLE)
        rgb_mode_idle();
    else if (new_status != OK)
        rgb_mode_error();
    else if (new_state == dfuMANIFEST_WAIT_RESET)
        rgb_mode_done();
    else
        rgb_mode_writing();
    dfu_state = new_state;
    dfu_status = new_status;
}

static bool ftfl_busy(void)
{
    if (ram_mode)
        return 0;

    // Is the flash memory controller busy?
    return spiIsBusy();
}

static void ftfl_busy_wait(void)
{
    // Wait for the flash memory controller to finish any pending operation.
    while (ftfl_busy())
        ;//watchdog_refresh();
}

static void ftfl_begin_erase_sector(uint32_t address)
{
    if (!ram_mode) {
        ftfl_busy_wait();
        // Only erase if it's on the page boundry.
        if ((address & ~(ERASE_SIZE - 1) ) == address)
            spiBeginErase4(address);
    }
    fl_state = flsERASING;
}

static void ftfl_write_more_bytes(void)
{
    uint32_t bytes_to_write = WRITE_SIZE;
    if (dfu_bytes_remaining < bytes_to_write)
        bytes_to_write = dfu_bytes_remaining;
    if (ram_mode) {
        memcpy((void *)dfu_target_address, &dfu_buffer[dfu_buffer_offset/4], bytes_to_write);
    }
    else {
        ftfl_busy_wait();
        spiBeginWrite(dfu_target_address, &dfu_buffer[dfu_buffer_offset/4], bytes_to_write);
    }

    dfu_bytes_remaining -= bytes_to_write;
    dfu_target_address += bytes_to_write;
    dfu_buffer_offset += bytes_to_write;
}

static void ftfl_begin_program_section(uint32_t address)
{
    // Write the buffer word to the currently selected address.
    // Note that after this is done, the address is incremented by 4.
    dfu_buffer_offset = 0;
    dfu_target_address = address;
    ftfl_write_more_bytes();
}

static uint32_t address_for_block(unsigned blockNum)
{
    uint32_t starting_offset;
    if (ram_mode)
        starting_offset = ram_mode;
    else
        starting_offset = CONFIG_RESCUE_IMAGE_OFFSET;

    return starting_offset + (blockNum * DFU_TRANSFER_SIZE);
}

void dfu_init(void)
{
    return;
}

uint8_t dfu_getstate(void)
{
    return dfu_state;
}

bool dfu_download(unsigned blockNum, unsigned blockLength,
                  unsigned packetOffset, unsigned packetLength, const uint8_t *data)
{
    if (packetOffset + packetLength > DFU_TRANSFER_SIZE ||
        packetOffset + packetLength > blockLength) {

        // Overflow!
        set_state(dfuERROR, errADDRESS);
        return false;
    }

    // Store more data...
    memcpy(((uint8_t *)dfu_buffer) + packetOffset, data, packetLength);

    // Check to see if we're writing to RAM instead of SPI flash
    if ((blockNum == 0) && (packetOffset == 0) && (packetLength > 0)) {
        unsigned int i = 0;
        unsigned int max_check = packetLength;
        if (max_check > sizeof(dfu_buffer))
            max_check = sizeof(dfu_buffer);
        for (i = 0; i < (max_check/4)-1; i++) {
            if (dfu_buffer[i/4] == RAM_BOOT_SENTINAL) {
                ram_mode = dfu_buffer[(i/4)+1];
                break;
            }
        }
    }

    if (packetOffset + packetLength != blockLength) {
        // Still waiting for more data.
        return true;
    }

    if (dfu_state != dfuIDLE && dfu_state != dfuDNLOAD_IDLE) {
        // Wrong state! Oops.
        set_state(dfuERROR, errSTALLEDPKT);
        return false;
    }

    if (ftfl_busy() || (fl_state != flsIDLE)) {
        // Flash controller shouldn't be busy now!
        set_state(dfuERROR, errWRITE);
        return false;
    }

    if (!blockLength) {
        // End of download
        set_state(dfuMANIFEST_SYNC, OK);
        return true;
    }

    // Start programming a block by erasing the corresponding flash sector
    fl_current_addr = address_for_block(blockNum);
    if (!ram_mode && (fl_current_addr >= FLASH_MAX_ADDR)) {
        set_state(dfuERROR, errADDRESS);
        return false;
    }

    dfu_bytes_remaining = blockLength;
    ftfl_begin_erase_sector(fl_current_addr);

    set_state(dfuDNLOAD_SYNC, OK);
    return true;
}

static void fl_state_poll(void)
{
    // Try to advance the state of our own flash programming state machine.

    if (spiIsBusy())
        return;

    switch (fl_state) {

    case flsIDLE:
        break;

    case flsERASING:
        fl_state = flsPROGRAMMING;
        ftfl_begin_program_section(fl_current_addr);
        break;

    case flsPROGRAMMING:
        // Program more blocks, if applicable
        if (dfu_bytes_remaining)
            ftfl_write_more_bytes();
        else
            fl_state = flsIDLE;
        break;
    }
}

void dfu_poll(void)
{
    if ((dfu_state == dfuDNLOAD_SYNC) || (dfu_state == dfuDNBUSY))
        fl_state_poll();
}

bool dfu_getstatus(uint8_t status[8])
{
    switch (dfu_state) {

        case dfuDNLOAD_SYNC:
        case dfuDNBUSY:

            if (dfu_state == dfuERROR) {
                // An error occurred inside fl_state_poll();
            } else if (fl_state == flsIDLE) {
                set_state(dfuDNLOAD_IDLE, OK);
            } else {
                set_state(dfuDNBUSY, OK);
            }
            dfu_poll_timeout_ms = BUSY_POLL_TIMEOUT_MS;
            break;

        case dfuMANIFEST_SYNC:
            // Ready to reboot. The main thread will take care of this. Also let the DFU tool
            // know to leave us alone until this happens.
            set_state(dfuMANIFEST, OK);
            dfu_poll_timeout_ms = MANIFEST_POLL_TIMEOUT_MS;
            break;

        case dfuMANIFEST:
            // Perform the reboot
            set_state(dfuMANIFEST_WAIT_RESET, OK);
            dfu_poll_timeout_ms = MANIFEST_TIMEOUT_MS;
            break;

        case dfuIDLE:
            dfu_poll_timeout_ms = IDLE_TIMEOUT_MS;
            break;

        default:
            break;
    }

    status[0] = dfu_status;
    status[1] = dfu_poll_timeout_ms;
    status[2] = dfu_poll_timeout_ms >> 8;
    status[3] = dfu_poll_timeout_ms >> 16;
    status[4] = dfu_state;
    status[5] = 0;  // iString

    return true;
}

bool dfu_clrstatus(void)
{
    switch (dfu_state) {

    case dfuERROR:
    case dfuIDLE:
    case dfuMANIFEST_WAIT_RESET:
        // Clear an error
        set_state(dfuIDLE, OK);
        return true;

    default:
        // Unexpected request
        set_state(dfuERROR, errSTALLEDPKT);
        return false;
    }
}

bool dfu_abort(void)
{
    set_state(dfuIDLE, OK);
    return true;
}
