Fobooster: the Foboot Updater
===========================

Foboot cannot update itself, because a partial flash would result in an unbootable system.

`Fobooster` is used to guide the installation of Foboot.  By appending a new version of Foboot to the end of Fobooster, we can create a program to update Foboot itself.

Usage
-----

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

EVT: 0xef177018
PVT: 0xc2152815
HAcker: 0x1f148601

The resulting `toboot-booster.bin` can be flashed with Toboot itself, or can be loaded using the legacy serial bootloader.

Design
------

Booster uses xxHash to verify the application is loaded correctly.  It also needs to know how many bytes to load.  To do this, it looks at the `fobooster_data` struct, which has the following format:

```c++
struct fobooster_data
{
    uint32_t payload_size;  // Number of bytes to flash
    uint32_t xxhash32;      // A hash of the entire program to be loaded
    uint32_t payload[0];    // The contents of the firmware to build
};
```

The `payload_size` value indicates the number of bytes to write.  Ideally it's a multiple of four.

The `xxhash32` is the result of a 32-bit xxHash operation.  The seed is defined in fobooster.h as `FOBOOSTER_SEED`, and is `0xc38b9e66L`.

Finally, `payload` is an array of uint32 values.

The `struct fobooster_data` object is placed directly following the program image.  The `make-booster` program copies the contents of `booster.bin` to a new file, then appends `struct booster_data` to the end.  That way, all `booster` has to do is refer to the contents of the struct in order to program the data.

As a happy coincidence, if `struct booster_data` is not populated (i.e. if you just flash the raw `booster.bin` to a device), then `xxhash32` will not be valid and `booster.bin` will simply reset the device.

Because a bitstream image is 104090 bytes, and the ICE40 has 131072 bytes of RAM, a bitstream fits entirely in RAM.  This allows us to validate the image is good prior to writing it to SPI flash.
