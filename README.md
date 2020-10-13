# Foboot: The Bootloader for Fomu

Foboot is a failsafe bootloader for Fomu.  It exposes a DFU interface to the host.  Foboot comes in two halves: A Software half and a Hardware half.  These two halves are integrated into a single "bitstream" that is directly loaded onto an ICE40UP5k board, such as Fomu.

## Requirements

To build the hardware, you need:

* Python 3.5+
* Nextpnr
* Icestorm
* Yosys
* Git

Subproject hardware dependencies will be taken care of with `lxbuildenv`.

To build the software, you need:

* RISC-V toolchain

## Building the project

The hardware half will take care of building the software half, if it is run with `--boot-source bios` (which is the default).  Therefore, to build Foboot, enter the `hw/` directory and run:

```
$ python3 foboot-bitstream.py --revision hacker --seed 19
```

This will verify you have the correct dependencies installed, compile the Foboot software, then synthesize the Foboot bitstream.  The resulting output will be in `build/gateware/`.  You should write `build/gateware/top-multiboot.bin` to your Fomu device in order to get basic bootloader support.

The `seed` argument is to set initial conditions for the
place-and-route phase.  `nextpnr-ice40` uses a simulated annealing
algorithm that can result in one of several locally optimal layouts.
Only some of these will meet the timing requirements for Fomu.

If you see something like
```
ERROR: Max frequency for clock 'clk48_$glb_clk': 45.41 MHz (FAIL at 48.00 MHz)
```
try a different seed.  You can search for an appropriate seed with:
```
for seed in $(seq 0 100)
do
  python3 ./foboot-bitstream.py --revision pvt --seed $seed 2>&1 |
     grep 'FAIL at 48.00 MHz' && continue
  echo "Working Seed is $seed"
  break
done
```
This can take a considerable time.

### Usage

You can write the bitstream to your SPI flash.

#### Loading using `fomu-flash`

If you're using `fomu-flash`, you would run the following:

```sh
$ fomu-flash -w build/gateware/top-multiboot.bin
Erasing @ 018000 / 01973a  Done
Programming @ 01973a / 01973a  Done
$ fomu-flash -r
resetting fpga
$
```

Fomu should now show up when you connect it to your machine:

```
[172294.296354] usb 1-1.3: new full-speed USB device number 33 using dwc_otg
[172294.445661] usb 1-1.3: New USB device found, idVendor=1209, idProduct=70b1
[172294.445675] usb 1-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[172294.445684] usb 1-1.3: Product: Fomu Bootloader (0)
[172294.445692] usb 1-1.3: Manufacturer: Kosagi
```

#### Using `dfu-util` to flash the bootloader

##### Safe way to test

Just do
```sh
dfu-util -D build/gateware/top.bin
```
to copy into the SPI flash, then
```sh
dfu-util -e
```
each time you want to run the generated bitstream after a reboot.

A multiboot enabled bootloader is also generated; you can try that out
with
```sh
dfu-util -D build/gateware/top-multiboot.bin
```

`dfu-util` loads the bootloader into flash at 0x40000; it'll be overridden
by any other code you attempt to flash using `dfu-util`

##### Loading the bootloader as first bootloader

**WARNING: Flashing a new bootloader could _brick your device_**
**It's best to wait for an official release**

First build the flasher program, that will run on the Fomu (you only
need to do this once):
```sh
cd booster
cc -O2 -o make-booster -I ./include make-booster.c
make
```

Then package everything up ready for loading:
```sh
cd releases
bash ./release.sh pvt
```
This will create a new directory in `releases` named by the head of
your git tree and the last official release.  So you'll see something
like `v2.0.3-8-g485d232`

In that directory will be a file named `pvt-updater-`_version_`.dfu`
Load  it onto the Fomu using `dfu-util`:
```sh
dfu-util -D pvt-updater-v2.0.3-8-g485d232.dfu
```
Your Fomu will flash rainbow for about five seconds, then reboot and
go back to blinking steadily.   To verify that your code has loaded, use
```sh
dfu-util -l
```
and look at the version output.

#### Loading and running other bitstreams
To load a new bitstream, use the `dfu-util -D` command.  For example:

```sh
$ dfu-util -D blink.bin
```

This will reflash the SPI beginning at offset 262144.

To exit DFU and run the bitstream at offset 262144, run:

```sh
$ dfu-util -e
```

**Note that, like Toboot, the program will auto-boot once it has finished loading.**

## Building the Software

Software is contained in the `sw/` directory.
