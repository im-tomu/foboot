# Foboot Firmware Component

## Usage

To build:

`python3 .\foboot-bitstream.py`

This will ensure you have the required dependencies, and check out all submodules.

## Tests

You can run tests by using the `unittest` command:

`python .\lxbuildenv.py -r -m unittest -v valentyusb.usbcore.cpu.epfifo_test.TestPerEndpointFifoInterface`