#ifndef _DFU_H
#define _DFU_H

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

#pragma once
#include <stdbool.h>
#include <stdint.h>

typedef enum {
    appIDLE = 0,
    appDETACH,
    dfuIDLE,
    dfuDNLOAD_SYNC,
    dfuDNBUSY,
    dfuDNLOAD_IDLE,
    dfuMANIFEST_SYNC,
    dfuMANIFEST,
    dfuMANIFEST_WAIT_RESET,
    dfuUPLOAD_IDLE,
    dfuERROR
} dfu_state_t;

typedef enum {
    OK = 0,
    errTARGET,
    errFILE,
    errWRITE,
    errERASE,
    errCHECK_ERASED,
    errPROG,
    errVERIFY,
    errADDRESS,
    errNOTDONE,
    errFIRMWARE,
    errVENDOR,
    errUSBR,
    errPOR,
    errUNKNOWN,
    errSTALLEDPKT,
} dfu_status_t;

#define DFU_INTERFACE             0
#define DFU_DETACH_TIMEOUT        10000     // 10 second timer
#define DFU_TRANSFER_SIZE         1024      // Flash sector size

// Main thread
void dfu_init();

// USB entry points. Always successful.
uint8_t dfu_getstate();

// USB entry points. True on success, false for stall.
bool dfu_getstatus(uint8_t status[8]);
bool dfu_clrstatus();
bool dfu_abort();
bool dfu_download(unsigned blockNum, unsigned blockLength,
unsigned packetOffset, unsigned packetLength, const uint8_t *data);

#endif /* _DFU_H */