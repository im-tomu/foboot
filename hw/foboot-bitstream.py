#!/usr/bin/env python3
# This variable defines all the external programs that this module
# relies on.  lxbuildenv reads this variable in order to ensure
# the build will finish without exiting due to missing third-party
# programs.
LX_DEPENDENCIES = ["riscv", "icestorm", "yosys"]

# Import lxbuildenv to integrate the deps/ directory
import lxbuildenv

# Disable pylint's E1101, which breaks completely on migen
#pylint:disable=E1101

#from migen import *
from migen import Module, Signal, Instance, ClockDomain, If
from migen.genlib.resetsync import AsyncResetSynchronizer
from litex.build.lattice.platform import LatticePlatform
from litex.build.generic_platform import Pins, IOStandard, Misc, Subsignal
from litex.soc.integration import SoCCore
from litex.soc.integration.builder import Builder
from litex.soc.integration.soc_core import csr_map_update
from litex.soc.interconnect import wishbone
from litex.soc.cores.spi import SPIMaster

from valentyusb import usbcore
from valentyusb.usbcore import io as usbio
from valentyusb.usbcore.cpu import epmem, unififo, epfifo
from valentyusb.usbcore.endpoint import EndpointType

from lxsocsupport import up5kspram, spi_flash

import argparse

_io = [
    ("serial", 0,
        Subsignal("rx", Pins("21")),
        Subsignal("tx", Pins("13"), Misc("PULLUP")),
        IOStandard("LVCMOS33")
    ),
    ("usb", 0,
        Subsignal("d_p", Pins("34")),
        Subsignal("d_n", Pins("37")),
        Subsignal("pullup", Pins("35")),
        IOStandard("LVCMOS33")
    ),
    ("pmoda", 0,
        Subsignal("p1", Pins("28"), IOStandard("LVCMOS33")),
        Subsignal("p2", Pins("27"), IOStandard("LVCMOS33")),
        Subsignal("p3", Pins("26"), IOStandard("LVCMOS33")),
        Subsignal("p4", Pins("23"), IOStandard("LVCMOS33")),
    ),
    ("pmodb", 0,
        Subsignal("p1", Pins("48"), IOStandard("LVCMOS33")),
        Subsignal("p2", Pins("47"), IOStandard("LVCMOS33")),
        Subsignal("p3", Pins("46"), IOStandard("LVCMOS33")),
        Subsignal("p4", Pins("45"), IOStandard("LVCMOS33")),
    ),
    ("spiflash", 0,
        Subsignal("cs_n", Pins("16"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("15"), IOStandard("LVCMOS33")),
        Subsignal("miso", Pins("17"), IOStandard("LVCMOS33")),
        Subsignal("mosi", Pins("14"), IOStandard("LVCMOS33")),
        Subsignal("wp",   Pins("18"), IOStandard("LVCMOS33")),
        Subsignal("hold", Pins("19"), IOStandard("LVCMOS33")),
    ),
    ("spiflash4x", 0,
        Subsignal("cs_n", Pins("16"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("15"), IOStandard("LVCMOS33")),
        Subsignal("dq",   Pins("14 17 19 18"), IOStandard("LVCMOS33")),
    ),
    ("clk48", 0, Pins("44"), IOStandard("LVCMOS33"))
]

_connectors = []

class _CRG(Module):
    def __init__(self, platform):
        clk48_raw = platform.request("clk48")
        clk12_raw = Signal()
        clk48 = Signal()
        clk12 = Signal()

        # Divide clk48 down to clk12, to ensure they're synchronized.
        # By doing this, we avoid needing clock-domain crossing.
        clk12_counter = Signal(2)

        # # "0b00" Sets 48MHz HFOSC output
        # # "0b01" Sets 24MHz HFOSC output.
        # # "0b10" Sets 12MHz HFOSC output.
        # # "0b11" Sets 6MHz HFOSC output
        # self.specials += Instance(
        #     "SB_HFOSC",
        #     i_CLKHFEN=1,
        #     i_CLKHFPU=1,
        #     o_CLKHF=clk12,
        #     p_CLKHF_DIV="0b10", # 12MHz
        # )

        self.clock_domains.cd_sys = ClockDomain()
        self.clock_domains.cd_usb_12 = ClockDomain()
        self.clock_domains.cd_usb_48 = ClockDomain()
        self.clock_domains.cd_usb_48_raw = ClockDomain()

        platform.add_period_constraint(self.cd_usb_48.clk, 1e9/48e6)
        platform.add_period_constraint(self.cd_usb_48_raw.clk, 1e9/48e6)
        platform.add_period_constraint(self.cd_sys.clk, 1e9/12e6)
        platform.add_period_constraint(self.cd_usb_12.clk, 1e9/12e6)
        platform.add_period_constraint(clk48, 1e9/48e6)
        platform.add_period_constraint(clk48_raw, 1e9/48e6)

        self.reset = Signal()

        # POR reset logic- POR generated from sys clk, POR logic feeds sys clk
        # reset.
        self.clock_domains.cd_por = ClockDomain()
        reset_delay = Signal(12, reset=4095)
        self.comb += [
            self.cd_por.clk.eq(self.cd_sys.clk),
            self.cd_sys.rst.eq(reset_delay != 0),
            self.cd_usb_12.rst.eq(reset_delay != 0),
            self.cd_usb_48.rst.eq(reset_delay != 0),
            # self.cd_usb_48_raw.rst.eq(reset_delay != 0),
        ]

        self.comb += self.cd_usb_48_raw.clk.eq(clk48_raw)
        self.comb += self.cd_usb_48.clk.eq(clk48)

        self.sync.usb_48_raw += clk12_counter.eq(clk12_counter + 1)

        self.comb += clk12_raw.eq(clk12_counter[1])
        self.specials += Instance(
            "SB_GB",
            i_USER_SIGNAL_TO_GLOBAL_BUFFER=clk12_raw,
            o_GLOBAL_BUFFER_OUTPUT=clk12,
        )
        platform.add_period_constraint(clk12_raw, 1e9/12e6)

        self.specials += Instance(
            "SB_PLL40_CORE",
            # Parameters
            p_DIVR = 0,
            p_DIVF = 3,
            p_DIVQ = 2,
            p_FILTER_RANGE = 1,
            p_FEEDBACK_PATH = "PHASE_AND_DELAY",
            p_DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED",
            p_FDA_FEEDBACK = 15,
            p_DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED",
            p_FDA_RELATIVE = 0,
            p_SHIFTREG_DIV_MODE = 1,
            p_PLLOUT_SELECT = "SHIFTREG_0deg",
            p_ENABLE_ICEGATE = 0,
            # IO
            i_REFERENCECLK = clk12,
            # o_PLLOUTCORE = clk12,
            o_PLLOUTGLOBAL = clk48,
            #i_EXTFEEDBACK,
            #i_DYNAMICDELAY,
            #o_LOCK,
            i_BYPASS = 0,
            i_RESETB = 1,
            #i_LATCHINPUTVALUE,
            #o_SDO,
            #i_SDI,
        )

        self.comb += self.cd_sys.clk.eq(clk12)
        self.comb += self.cd_usb_12.clk.eq(clk12)

        self.sync.por += \
            If(reset_delay != 0,
                reset_delay.eq(reset_delay - 1)
            )
        self.specials += AsyncResetSynchronizer(self.cd_por, self.reset)

class RandomFirmwareROM(wishbone.SRAM):
    """
    Seed the random data with a fixed number, so different bitstreams
    can all share firmware.
    """
    def __init__(self, size, seed=2373):
        def xorshift32(x):
            x = x ^ (x << 13) & 0xffffffff
            x = x ^ (x >> 17) & 0xffffffff
            x = x ^ (x << 5)  & 0xffffffff
            return x & 0xffffffff

        def get_rand(x):
            out = 0
            for i in range(32):
                x = xorshift32(x)
                if (x & 1) == 1:
                    out = out | (1 << i)
            return out & 0xffffffff
        data = []
        seed = 1
        for d in range(int(size / 4)):
            seed = get_rand(seed)
            data.append(seed)
        wishbone.SRAM.__init__(self, size, read_only=True, init=data)

class Platform(LatticePlatform):
    default_clk_name = "clk48"
    default_clk_period = 20.833

    gateware_size = 0x20000

    def __init__(self, toolchain="icestorm"):
        LatticePlatform.__init__(self, "ice40-up5k-sg48", _io, _connectors, toolchain="icestorm")
        # Add "-relut -dffe_min_ce_use 4" to the synth_ice40 command.
        # The "-reult" adds an additional LUT pass to pack more stuff in,
        # and the "-dffe_min_ce_use 4" flag prevents Yosys from generating a
        # Clock Enable signal for a LUT that has fewer than 4 flip-flops.
        # This increases density, and lets us use the FPGA more efficiently.
        for i in range(len(self.toolchain.nextpnr_yosys_template)):
            entry = self.toolchain.nextpnr_yosys_template[i]
            if "synth_ice40" in entry:
                self.toolchain.nextpnr_yosys_template[i] = entry + " -dsp -relut -dffe_min_ce_use 4"
    def create_programmer(self):
        raise ValueError("programming is not supported")

    # def do_finalize(self, fragment):
        # LatticePlatform.do_finalize(self, fragment)

class BaseSoC(SoCCore):
    csr_peripherals = [
        "cpu_or_bridge",
        "usb",
        "usb_obuf",
        "usb_ibuf",
        "spi",
    ]
    csr_map_update(SoCCore.csr_map, csr_peripherals)

    mem_map = {
        "spiflash": 0x20000000,  # (default shadow @0xa0000000)
    }
    mem_map.update(SoCCore.mem_map)

    interrupt_map = {
        "usb": 3,
    }
    interrupt_map.update(SoCCore.interrupt_map)

    def __init__(self, platform, boot_source="random_rom", debug=False, **kwargs):
        # Disable integrated RAM as we'll add it later
        self.integrated_sram_size = 0

        clk_freq = int(12e6)
        self.submodules.crg = _CRG(platform)

        SoCCore.__init__(self, platform, clk_freq, integrated_sram_size=0, **kwargs)

        if debug:
            self.cpu.use_external_variant("vexriscv-2-stage-with-debug.v")
            self.register_mem("vexriscv_debug", 0xf00f0000, self.cpu.debug_bus, 0x10)

        # SPRAM- UP5K has single port RAM, might as well use it as SRAM to
        # free up scarce block RAM.
        spram_size = 128*1024
        self.submodules.spram = up5kspram.Up5kSPRAM(size=spram_size)
        self.register_mem("sram", 0x10000000, self.spram.bus, spram_size)

        if boot_source == "random_rom":
            kwargs['cpu_reset_address']=0
            bios_size = 0x2000
            self.submodules.random_rom = RandomFirmwareROM(bios_size)
            self.add_constant("ROM_DISABLE", 1)
            self.register_rom(self.random_rom.bus, bios_size)
        elif boot_source == "bios_rom":
            kwargs['cpu_reset_address']=0
            bios_size = 0x2000
            self.add_memory_region("rom", kwargs['cpu_reset_address'], bios_size)
        elif boot_source == "spi_rom":
            bios_size = 0x8000
            kwargs['cpu_reset_address']=self.mem_map["spiflash"]+platform.gateware_size
            self.add_memory_region("rom", kwargs['cpu_reset_address'], bios_size)
            self.add_constant("ROM_DISABLE", 1)
            self.flash_boot_address = self.mem_map["spiflash"]+platform.gateware_size+bios_size
            self.add_memory_region("user_flash",
                self.flash_boot_address,
                # Leave a grace area- possible one-by-off bug in add_memory_region?
                # Possible fix: addr < origin + length - 1
                platform.spiflash_total_size - (self.flash_boot_address - self.mem_map["spiflash"]) - 0x100)
        else:
            raise ValueError("unrecognized boot_source: {}".format(boot_source))

        spi_pads = platform.request("spiflash")
        self.submodules.spi = SPIMaster(spi_pads)

        # Add USB pads
        usb_pads = platform.request("usb")
        usb_iobuf = usbio.IoBuf(usb_pads.d_p, usb_pads.d_n, usb_pads.pullup)
        self.submodules.usb = epfifo.PerEndpointFifoInterface(usb_iobuf, endpoints=[EndpointType.BIDIR])
        # self.submodules.usb = epmem.MemInterface(usb_iobuf)
        # self.submodules.usb = unififo.UsbUniFifo(usb_iobuf)

        # Disable final deep-sleep power down so firmware words are loaded
        # onto softcore's address bus.
        platform.toolchain.build_template[3] = "icepack -s {build_name}.txt {build_name}.bin"
        platform.toolchain.nextpnr_build_template[2] = "icepack -s {build_name}.txt {build_name}.bin"

def main():
    platform = Platform()

    parser = argparse.ArgumentParser(
        description="Build Fomu Main Gateware",
        add_help=False)
    parser.add_argument(
        "--bios", help="use bios as boot source", action="store_true"
    )
    parser.add_argument(
        "--rand", help="use random data as boot source", action="store_false"
    )
    parser.add_argument(
        "--spi", help="boot from spi", action="store_true"
    )
    parser.add_argument(
        "--with-debug", help="enable debug support", action="store_true"
    )
    (args, rest) = parser.parse_known_args()

    debug = False
    cpu_variant = "min"
    if args.rand:
        boot_source="random_rom"
        compile_software=False
    elif args.bios:
        boot_source="bios_rom"
        compile_software=True
    elif args.spi:
        boot_source = "spi_rom"
        compile_software = False
    if args.with_debug:
        cpu_variant = "debug"
        debug = True
    else:
        cpu_variant = "min"
        debug = False

    soc = BaseSoC(platform, cpu_type="vexriscv", cpu_variant=cpu_variant, debug=debug, boot_source=boot_source)
    builder = Builder(soc, output_dir="build", csr_csv="test/csr.csv", compile_software=compile_software)
    vns = builder.build()
    soc.do_exit(vns)

if __name__ == "__main__":
    main()
