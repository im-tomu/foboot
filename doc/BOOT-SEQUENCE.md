# Fomu Boot Sequence

When Foboot starts, it must decide which mode to go into.  The following modes are defined:

| Mode Name | Short Name | Description  |
| --------- | ---------- | ------------ |
| Foboot Rescue | **FBU** | Initial state -- rescue mode uses DFU |
| Foboot Main | **FBM** | Presents a disk drive that makes it easy to load programs |
| User Python Program | **UPY** | Uses a locally-stored Python interpreter to run Python code |
| User RISC-V Program | **URV** | Uses the built-in RISC-V softcore to execute user programs |
| User ICE40 Bitstream | **UBS** | Exits the Foboot RISC-V core and switches to the provided bitstream |

At start, **FBU** is loaded by the hardware.  **FBU** will look for a special *FBM signature* at a given offset.  If this signature exists, it will transfer execution to that program.  Otherwise it will enter *DFU Mode* and await further communication.

## Boot Flags

A series of *Boot Fags* determine how **FBU** and **FBM** hand over execution to the subsequent program.

*Boot Flags* are indicated by the magic number `0xb469075a`, followed by a
32-bit field, in the first 128 bytes of the binary.

It's similar to the following C struct:

```c
struct {
    uint32_t magic;    // 0xb469075a
    uint32_t bitfield;
}
```

| Bit Flag | Short Name   | Description                                      |
| -------- | ------------ | ------------------------------------------------ |
| 00000001 | QPI_EN       | Enable QPI mode on the SPI flash                 |
| 00000002 | DDR_EN       | Enable DDR mode on the SPI flash                 |
| 00000004 | CFM_EN       | Enable CFM mode on the SPI flash                 |
| 00000008 | FLASH_UNLOCK | Don't lock flash prior to running program        |
| 00000010 | FLUSH_CACHE  | Issue a "fence.i" prior to running user program  |
| 00000020 | NO_USB_RESET | Don't reset the USB -- useful for debugging      |

## RAM boot

During development, it may be inconvenient to load a program onto SPI flash.  Or maybe you want to run something that doesn't modify the contents of SPI.  This is possible with `RAM boot`.

If the DFU bootloader encounters the magic number `0x17ab0f23` within the first 56 bytes, then it will enable *RAM boot* mode.  In this mode, the SPI flash won't be erased, and the program will be loaded to RAM.

Note that the value following the magic number indicates the offset where the program will be loaded to.  This should be somewhere in RAM.  `0x10001000` is a good value, and is guaranteed to not interfere with Foboot itself.

## Magic Numbers

| Value        | Description                                 |
| ------------ | ------------------------------------------- |
| `0xb469075a` | Denotes the start of *boot flags* bitfield  |
| `0x17ab0f23` | Loads the program into RAM instead of flash |
| `0x032bd37d` | Indicates a valid **FBM** image             |