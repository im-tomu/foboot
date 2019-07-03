# Fomu

|  Hex Address | Decimal Address  | Used by  |  Purpose |
|---:|---:|---|---|
| 0x0000a0 | 160 | HDL in multiboot header |  The image loaded at first boot, DFU bootloader image |
| 0x0000a0 | 160 | HDL in multiboot header |  The first image for SB_WARMBOOT, DFU bootloader image |
| 0x01a000 | 106496 | main.c as FBM_OFFSET  | Used to contain user s/w, is loaded over DFU s/w if found and touch not pressed |
| 0x026800 | 157696  |  The second image for SB_WARMBOOT |
| 0x040000 | 262144  |  The third image for SB_WARMBOOT |
| 0x048000 | 294912  |  The third image for SB_WARMBOOT |
| 0x1FFFFF | 20097151 | End of flash |
