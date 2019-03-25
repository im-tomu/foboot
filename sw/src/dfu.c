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

#include <toboot-api.h>
#include <toboot-internal.h>
#include <dfu.h>

#define BLOCK_SIZE 32768 // bytes

#include <spi.h>
extern struct ff_spi *spi; // Defined in main.c

// Internal flash-programming state machine
static unsigned fl_current_addr = 0;
static enum {
    flsIDLE = 0,
    flsERASING,
    flsPROGRAMMING
} fl_state;

static struct toboot_state {
    // Version number of the program being loaded:
    //  0 (legacy)
    //  1 (toboot v1)
    //  2 (toboot v2)
    uint8_t version;

    // When clearing, first ensure these sectors are cleared prior to updating
    uint32_t clear_lo;
    uint32_t clear_hi;

    // The current block we're clearing
    uint32_t clear_current;

    // This is the address we'll start programming/erasing from after clearing
    uint32_t next_addr;

    enum {
        /// Toboot has just started
        tbsIDLE,

        /// Secure erase memory is being cleared
        tbsCLEARING,

        /// New image is being loaded
        tbsLOADING,
    } state;
} tb_state;

static dfu_state_t dfu_state = dfuIDLE;
static dfu_status_t dfu_status = OK;
static unsigned dfu_poll_timeout = 100;

static uint32_t dfu_buffer[DFU_TRANSFER_SIZE/4];
static uint32_t dfu_buffer_offset;
static uint32_t dfu_bytes_remaining;

// Memory offset we're uploading to.
static uint32_t dfu_target_address;

static void set_state(dfu_state_t new_state, dfu_status_t new_status) {
    dfu_state = new_state;
    dfu_status = new_status;
}

bool fl_is_idle(void) {
    return fl_state == flsIDLE;
}

static bool ftfl_busy()
{
    // Is the flash memory controller busy?
    return spiIsBusy(spi);
}

static void ftfl_busy_wait()
{
    // Wait for the flash memory controller to finish any pending operation.
    while (ftfl_busy())
        ;//watchdog_refresh();
}

static void ftfl_begin_erase_sector(uint32_t address)
{
    ftfl_busy_wait();
    spiBeginErase(spi, address);
}

static void ftfl_write_more_bytes(void)
{
    uint32_t bytes_to_write = 256;
    if (dfu_bytes_remaining < bytes_to_write)
        bytes_to_write = dfu_bytes_remaining;
    ftfl_busy_wait();
    spiBeginWrite(spi, dfu_target_address, &dfu_buffer[dfu_buffer_offset], bytes_to_write);

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
    static const uint32_t starting_offset = 262144;
    // if (blockNum == 0) {
    //     // Determine Toboot version.
    //     if ((dfu_buffer[0x94 / 4] & TOBOOT_V2_MAGIC_MASK) == TOBOOT_V2_MAGIC) {
    //         tb_state.version = 2;
    //         starting_offset = ((struct toboot_configuration *)&dfu_buffer[0x94 / 4])->start;
    //     }
    //     // V1 used a different offset.
    //     else if ((dfu_buffer[0x98 / 4] & TOBOOT_V1_MAGIC_MASK) == TOBOOT_V1_MAGIC) {
    //         // Applications that know about Toboot will indicate their block
    //         // offset by placing a magic byte at offset 0x98.
    //         // Ordinarily this would be the address offset for IRQ 22,
    //         // but since there are only 20 IRQs on the EFM32HG, there are three
    //         // 32-bit values that are unused starting at offset 0x94.
    //         // We already use offset 0x94 for "disable boot", so use offset 0x98
    //         // in the incoming stream to indicate flags for Toboot.
    //         tb_state.version = 1;
    //         starting_offset = (dfu_buffer[0x98 / 4] & TOBOOT_V1_APP_PAGE_MASK) >> TOBOOT_V1_APP_PAGE_SHIFT;
    //     }
    //     // Legacy programs default to offset 0x4000.
    //     else {
    //         tb_state.version = 0;
    //         starting_offset = 16;
    //     }

    //     // Set the state to "CLEARING", since we're just starting the programming process.
    //     tb_state.state = tbsCLEARING;
    //     starting_offset *= 0x400;
    // }
    return starting_offset + (blockNum * BLOCK_SIZE);
}

// If requested, erase sectors before loading new code.
static void pre_clear_next_block(void) {
#pragma warning "Support for sector erasing has been disabled"
#if 0
    // If there is another sector to clear, do that.
    while (++tb_state.clear_current < 64) {
        if (tb_state.clear_current < 32) {
            if ((tb_state.clear_lo & (1 << tb_state.clear_current))) {
                ftfl_begin_erase_sector(tb_state.clear_current * 1024);
                return;
            }
        }
        else if (tb_state.clear_current < 64) {
            if ((tb_state.clear_hi & (1 << (tb_state.clear_current & 31)))) {
                ftfl_begin_erase_sector(tb_state.clear_current * 1024);
                return;
            }
        }
    }
#endif
    // No more sectors to clear, continue with programming
    tb_state.state = tbsLOADING;
    ftfl_begin_erase_sector(tb_state.next_addr);
}

void dfu_init(void)
{
    tb_state.state = tbsIDLE;
}

uint8_t dfu_getstate(void)
{
    return dfu_state;
}

bool dfu_download(unsigned blockNum, unsigned blockLength,
    unsigned packetOffset, unsigned packetLength, const uint8_t *data)
{
    uint32_t i;

    if (packetOffset + packetLength > DFU_TRANSFER_SIZE ||
        packetOffset + packetLength > blockLength) {

        // Overflow!
        set_state(dfuERROR, errADDRESS);
        return false;
    }

    // Store more data...
    memcpy(((uint8_t *)dfu_buffer) + packetOffset, data, packetLength);

    if (packetOffset + packetLength != blockLength) {
        // Still waiting for more data.
        return true;
    }

    if (dfu_state != dfuIDLE && dfu_state != dfuDNLOAD_IDLE) {
        // Wrong state! Oops.
        set_state(dfuERROR, errSTALLEDPKT);
        return false;
    }

    if (ftfl_busy() || fl_state != flsIDLE) {
        // Flash controller shouldn't be busy now!
        set_state(dfuERROR, errUNKNOWN);
        return false;       
    }

    if (!blockLength) {
        // End of download
        set_state(dfuMANIFEST_SYNC, OK);
        return true;
    }

    // Start programming a block by erasing the corresponding flash sector
    fl_state = flsERASING;
    fl_current_addr = address_for_block(blockNum);
    dfu_bytes_remaining = blockLength;

    // If it's the first block, figure out what we need to do in terms of erasing
    // data and programming the new file.
    if (blockNum == 0) {
        const struct toboot_configuration *old_config = tb_get_config();

        // Don't allow overwriting Toboot itself.
        if (fl_current_addr < tb_first_free_address()) {
            set_state(dfuERROR, errADDRESS);
            return false;
        }

        // Calculate generation number and hash
        if (tb_state.version == 2) {
            struct toboot_configuration *new_config = (struct toboot_configuration *)&dfu_buffer[0x94 / 4];

            // Update generation number
            new_config->reserved_gen = old_config->reserved_gen + 1;

            // Ensure we know this header is not fake
            new_config->config &= ~TOBOOT_CONFIG_FAKE;

            // Generate a valid signature
            tb_sign_config(new_config);
        }

        // If the old configuration requires that certain blocks be erased, do that.
        tb_state.clear_hi = old_config->erase_mask_hi;
        tb_state.clear_lo = old_config->erase_mask_lo;
        tb_state.clear_current = 0;

        // Ensure we don't erase Foboot itself
        for (i = 0; i < tb_first_free_sector(); i++) {
            if (i < 32)
                tb_state.clear_lo &= ~(1 << i);
            else
                tb_state.clear_hi &= ~(1 << i);
        }

        // If the newly-loaded program does not conform to Foboot V2.0, then look
        // for any existing programs on the flash and delete those sectors.
        // Because of boot priority, we need to ensure that no V2.0 applications
        // exist on flash.
        if (tb_state.version < 2) {
            for (i = tb_first_free_sector(); i < 64; i++) {
                if (tb_valid_signature_at_page(i) < 0)
                    continue;
                if (i < 32)
                    tb_state.clear_lo |= (1 << i);
                else
                    tb_state.clear_hi |= (1 << (i - 32));
            }
        }

        // If we still have sectors to clear, do that.  Otherwise,
        // go straight into loading the program.
        if (tb_state.clear_lo || tb_state.clear_hi) {
            tb_state.state = tbsCLEARING;
            tb_state.next_addr = fl_current_addr;
            pre_clear_next_block();
        }
        else {
            tb_state.state = tbsLOADING;
            ftfl_begin_erase_sector(fl_current_addr);
        }
    }
    else
        ftfl_begin_erase_sector(fl_current_addr);

    set_state(dfuDNLOAD_SYNC, OK);
    return true;
}

static void fl_state_poll(void)
{
    // Try to advance the state of our own flash programming state machine.

    int spi_is_busy = spiIsBusy(spi);

    switch (fl_state) {

        case flsIDLE:
            break;

        case flsERASING:
            if (spi_is_busy)
                break;

            // If we're still pre-clearing, continue with that.
            if (tb_state.state == tbsCLEARING) {
                pre_clear_next_block();
            }
            // Done! Move on to programming the sector.
            else {
                fl_state = flsPROGRAMMING;
                ftfl_begin_program_section(fl_current_addr);
            }
            break;

        case flsPROGRAMMING:
            if (spi_is_busy)
                break;

            // Program more blocks, if applicable
            if (dfu_bytes_remaining)
                ftfl_write_more_bytes();
            else
                fl_state = flsIDLE;
            break;
    }
}

bool dfu_getstatus(uint8_t status[8])
{
    switch (dfu_state) {

        case dfuDNLOAD_SYNC:
        case dfuDNBUSY:
            // Programming operation in progress. Advance our private flash state machine.
            fl_state_poll();

            if (dfu_state == dfuERROR) {
                // An error occurred inside fl_state_poll();
            } else if (fl_state == flsIDLE) {
                dfu_state = dfuDNLOAD_IDLE;
            } else {
                dfu_state = dfuDNBUSY;
            }
            break;

        case dfuMANIFEST_SYNC:
            // Ready to reboot. The main thread will take care of this. Also let the DFU tool
            // know to leave us alone until this happens.
            dfu_state = dfuMANIFEST;
            dfu_poll_timeout = 10;
            break;

        case dfuMANIFEST:
            // Perform the reboot
            dfu_state = dfuMANIFEST_WAIT_RESET;
            dfu_poll_timeout = 1000;
            break;

        default:
            break;
    }

    status[0] = dfu_status;
    status[1] = dfu_poll_timeout;
    status[2] = dfu_poll_timeout >> 8;
    status[3] = dfu_poll_timeout >> 16;
    status[4] = dfu_state;
    status[5] = 0;  // iString

    return true;
}

bool dfu_clrstatus(void)
{
    switch (dfu_state) {

    case dfuERROR:
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