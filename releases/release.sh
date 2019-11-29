#!/bin/bash
set -e
set -x

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"
platform="$1"
input=$root/hw/build

if [ -z $platform ]
then
	echo "Usage: $0 [platform]"
	echo "Where [platform] is one of: evt, evt-spi, pvt, hacker"
	exit 1
fi

if [ $platform = evt ]
then
	spi_id=0xef177018
elif [ $platform = evt-spi ]
then
	spi_id=0xef177018
elif [ $platform = pvt ]
then
	spi_id=0xc2152815
elif [ $platform = hacker ]
then
	spi_id=0x1f148601
else
	echo "Unrecognized platform $platform. Supported platforms: evt, evt-spi, pvt, hacker"
	exit 1
fi

cd $root
release=$(git describe --tags --dirty=+)
output=$root/releases/$release

mkdir -p $output
cp $input/gateware/top.bin $output/${platform}-foboot-${release}.dfu
cp $input/gateware/top-multiboot.bin $output/${platform}-multiboot-${release}.bin
cp $input/software/bios/bios.elf $output/${platform}-bios-${release}.elf
cp $input/software/include/generated/csr.h $output/${platform}-csr-${release}.h
cp $input/software/include/generated/soc.h $output/${platform}-soc-${release}.h
cd $root/booster
./make-booster $spi_id $input/gateware/top-multiboot.bin $output/${platform}-updater-${release}.dfu
dfu-suffix -v 1209 -p 70b1 -a $output/${platform}-updater-${release}.dfu
dfu-suffix -v 1209 -p 70b1 -a $output/${platform}-foboot-${release}.dfu
