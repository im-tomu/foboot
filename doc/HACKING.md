# Hacking on Foboot

Foboot lives inside an FPGA bitstream.  This bitstream is fragile and can take a lot of time to build.  Because of this, rapid changes to the code can be difficult to make.

There are two ways around this: Either store Foboot on a SPI flash and use XIP, or swap out the program ROM before loading the bitstream.

The bitstream generation program supports both approaches, however for development with an EVT board and `fomu-flash`, it is recommended to use the program-swap method.

## Replacing the boot ROM

When synthesizing a bitstream, a program ROM is loaded with the `$readmemh()` instruction.  Synthesis is inherently random, and so the mapping of bits within the bitstream file is very different from the mapping as seen by the softcore.

There is, however, some pattern to the mapping, and with some heuristics it is possible to create a mapping and swap bits out.  It is better to fill the ROM with random data, so that this process can ensure that it's replacing the correct bits -- if the ROM is entirely filled with zeroes, then it's impossible to know if the bit you're replacing is the correct one.

One program to do this is `icebram`, which is part of *Project Icestorm*.  The `fomu-flash` utility also has an option to patch the rom as it uploads the bitstream.  Currently, `fomu-flash` relies on a predefined "random" pattern, and requires the ROM to be 8192 bytes.  This limitation can be adjusted if a usecase is found.  The `fomu-flash` patching process is very fast.

### Building Foboot with a random ROM

To build Foboot with a random rom, add `--boot-source rand` to the build command:

```
$ python3 ./foboot-bitstream.py --boot-source rand --revision evt
```

This will synthesize a bitstream and store the result in `build/gateware/top.bin`.  This is a fully-working bitstream, however it has no ROM, and so doesn't do anything useful.  To actually do something with it, we need to build a ROM and patch it in.

### Building Foboot software

Normally, Foboot is built as part of the HW build process.  You can build it separately by going to the `sw/` directory and typing `make`.  This will generate several files.  Of interest is `foboot.bin`.

Note that if you change major components from the HW part, you will need to regenerate the CSR header files.  Copy them from `hw/build/software/include/generated/` into `sw/include/generated/`.

### Patching the ROM

To patch the ROM and load a new bitstream using `fomu-flash`, run:

```
$ fomu-flash -f hw/build/gateware/top.bin -l sw/foboot.bin`
```

This will reset the Fomu, patch the bitstream, and load the new bitstream into the FPGA.

### Patching the ROM with icebram

The `icebram` command also has the ability to patch the bitstream, however it requires files to be in a specific format.

To begin with, you need the following Python program to convert `foboot.bin` to a suitable `foboot.hex` file:

```python
#!/usr/bin/env python3
def swap32(d):
    d = list(d)
    while len(d) < 4:
        d.append(0)
    t = d[0]
    d[0] = d[3]
    d[3] = t

    t = d[1]
    d[1] = d[2]
    d[2] = t
    return bytes(d)

with open("foboot.bin", "rb") as inp:
    with open("foboot.hex", "w", newline="\n") as outp:
        while True:
            d = inp.read(4)
            if len(d) == 0:
                break
            print(swap32(d).hex(), file=outp)
```

Then, you need to generate a padded `random.hex` file from the foboot bitstream (the actual `--revision` doesn't matter, but must be something valid):

```
$ python3 ./foboot-bitstream.py --export-random-rom-file random.hex --revision evt
```

Then, you can use a script to patch the ROM:

```sh
$ icepack -u ~/top.bin | icebram random.hex foboot.hex | icepack - top-patched.bin
```

This will result in a file called `top-patched.bin` that can be written.

## Running Tests

You can run tests by using the `unittest` command:

`python3 lxbuildenv.py -r -m unittest -v valentyusb.usbcore.cpu.epfifo_test.TestPerEndpointFifoInterface`

Note that many tests are not working at this time, due to issues in how CSRs and events are handled in litex simulation.