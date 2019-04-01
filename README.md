# Foboot: The Bootloader for Fomu

Foboot is a failsafe bootloader for Fomu.  It exposes a DFU interface to the host.  Foboot comes in two halves: A Software half and a Hardware half.

## Building the Hardware

The hardware half is written in LiteX, and uses `lxbuildenv` to handle Python dependencies.  Hardware is contained within the `hw/` directory.  You must install software dependencies yourself:

* Python 3.5+
* Nextpnr
* Icestorm
* Yosys
* Git

Subproject dependencies will be taken care of with `lxbuildenv`.

### Usage

To build, run `foboot-bitstream.py`:

`python3 .\foboot-bitstream.py`

There are multiple build options available.  Use `--help` to list them.

Build files will be generated in the `build/` directory.  You will probably be most interested in `build/gateware/top.bin` and `build/software/include/generated/`.

## Tests

You can run tests by using the `unittest` command:

`python .\lxbuildenv.py -r -m unittest -v valentyusb.usbcore.cpu.epfifo_test.TestPerEndpointFifoInterface`

## Building the Software

Software is contained in the `sw/` directory.