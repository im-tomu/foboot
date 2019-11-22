# Booster: the Foboot Updater

Foboot cannot update itself.  It resides at offset 0, and writes to offset
`0x40000`.  Any errors in writing would result in an unbootable device.

`Booster` is used to guide the installation of Foboot.  Much like a booster
rocket helps guide a payload into orbit, Booster guides the installation of
Foboot, and is then discarded.

## Usage

First, compile fobooster.  Then, append the application header, and finally append the application itself.  This can be accomplished with `make-booster`.

```sh
cd toboot/
make
cd ../booster/
make
gcc make-booster.c -o make-booster
./make-booster [flash-id] ../toboot/toboot.bin toboot-booster.bin
```

The following flash-id values are known:

* EVT: 0xef177018
* PVT: 0xc2152815
* Hacker: 0x1f148601

The resulting `foboot-booster.bin` can be flashed with Foboot itself as
an ordinary program.

## Design

The goal of Booster is to load a new bitstream onto Fomu.  Because this
bitstream contains code + a CPU, Booster will actually run from within
the context of this new CPU.

**THE NEW IMAGE IS ASSUMED TO BE 0x19700 (104192) BYTES LONG**.  The new
image is padded by appending 0-bytes to it in order to get it to the
correct length.

The SPI flash image looks something like this:

| Hex Address | Decimal Address  | Purpose                                                                     |
|------------:|-----------------:|-----------------------------------------------------------------------------|
| 0x000000    | 0                | Instructs the FPGA where to find SB_WARMBOOT images S0-S3 and for cold boot |
| 0x0000a0    | 160              | Normal offset for Foboot                                                    |
| 0x040000    | 262144           | New version of Foboot, including new CPU Core                               |
| 0x05a000    | 368640           | Start of Booster program                                                    |
| 0x05a004    | 368644           | Booster signature                                                           |
| 0x05a008    | 368648           | Booster length (not including bitstream / new image)                        |
| 0x05a00c    | 368652           | Booster checksum                                                            |
| 0x05a010    | 368656           | Actual length of new image                                                  |
| 0x05a014    | 368660           | Length of xxHash region                                                     |
| 0x05a018    | 368664           | xxHash seed                                                                 |
| 0x05a01c    | 368668           | SPI ID of the target device                                                 |
| 0x1FFFFF    | 20097151         | End of flash                                                                |

The "Booster Signature" is `0x4260fa37` -- if it contains this value, then
this might be a Booster program.

The "Booster Checksum" is the result of summing together `[Booster length]`
8-bit bytes, starting at offset `0x05a010`.  If this value is equal to
`Booster checksum`, then Foboot will simply transfer control over to address
`0x05a000`.

### Booster execution flow

The first thing Booster does is validate the new image.  It does this by
performing an `xxHash` of the new image, from address `0x040000`.  If the image
does not match the hash, it will erase itself and show an error.

Next, Booster will validate that the start of the target image has a valid
SB_WARMBOOT header.  This specialized check ensures we don't accidentally write
an invalid image.

If the address matches, it checks the SPI ID.  If the ID does not match, then
it will erase itself and show an error.  Note that on some boards, such as
PVT, there are multiple IDs that could match, so they are all treated the same.

If the ID does match, the update will begin.

The first step of the update is to erase block 0 and reprogram it with a
temporary block that will point execution to address `0x400a0`.  This offset
means that we can switch from the updater to Foboot by rewriting the execution
address from `0x4000a0` to `0x0000a0`.

**From this point forward, Booster is effectively the only program on flash.**

Booster will then proceed to write each block in turn.  If the user unplugs
the device in the middle of writing, then Booster will start back up where
it left off.  Booster will not overwrite a block that doesn't need updating.

After Booster has finished, it must reboot itself.  The problem here is that
we can't simply issue an SB_WARMBOOT request since that has already been
programmed to load our image at `0x400000` -- we'd simply execute Booster again!

To work around this issue, Booster destroys itself.  First it updates the
SB_WARMBOOT block to point back to address 0.  Then, it simply erases
`0x5a000`, which clears the special image.

Finally, it reboots.  The ICE40 will load our image at `0x400000` (instead of
from `0x0`), however this shouldn't be an issue since we've already verified
that image is correct, and both should be identical.  If the user unplugs the
device and re-inserts it, they will get the image at `0x0` as usual.
