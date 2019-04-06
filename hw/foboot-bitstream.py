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
from migen.fhdl.specials import TSTriple
from migen.fhdl.structure import ClockSignal, ResetSignal, Replicate, Cat

from litex.build.lattice.platform import LatticePlatform
from litex.build.generic_platform import Pins, IOStandard, Misc, Subsignal
from litex.soc.integration import SoCCore
from litex.soc.integration.builder import Builder
from litex.soc.integration.soc_core import csr_map_update
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage

from valentyusb import usbcore
from valentyusb.usbcore import io as usbio
from valentyusb.usbcore.cpu import epmem, unififo, epfifo
from valentyusb.usbcore.endpoint import EndpointType

from lxsocsupport import up5kspram, spi_flash

import argparse
import os

_io_evt = [
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
    ("led", 0,
        Subsignal("rgb0", Pins("39"), IOStandard("LVCMOS33")),
        Subsignal("rgb1", Pins("40"), IOStandard("LVCMOS33")),
        Subsignal("rgb2", Pins("41"), IOStandard("LVCMOS33")),
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
_io_dvt = [
    ("serial", 0,
        Subsignal("rx", Pins("C3")),
        Subsignal("tx", Pins("B3"), Misc("PULLUP")),
        IOStandard("LVCMOS33")
    ),
    ("usb", 0,
        Subsignal("d_p", Pins("A1")),
        Subsignal("d_n", Pins("A2")),
        Subsignal("pullup", Pins("A4")),
        IOStandard("LVCMOS33")
    ),
    ("led", 0,
        Subsignal("rgb0", Pins("A5"), IOStandard("LVCMOS33")),
        Subsignal("rgb1", Pins("B5"), IOStandard("LVCMOS33")),
        Subsignal("rgb2", Pins("C5"), IOStandard("LVCMOS33")),
    ),
    ("spiflash", 0,
        Subsignal("cs_n", Pins("C1"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("D1"), IOStandard("LVCMOS33")),
        Subsignal("miso", Pins("E1"), IOStandard("LVCMOS33")),
        Subsignal("mosi", Pins("F1"), IOStandard("LVCMOS33")),
        Subsignal("wp",   Pins("F2"), IOStandard("LVCMOS33")),
        Subsignal("hold", Pins("B1"), IOStandard("LVCMOS33")),
    ),
    ("spiflash4x", 0,
        Subsignal("cs_n", Pins("C1"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("D1"), IOStandard("LVCMOS33")),
        Subsignal("dq",   Pins("E1 F1 F2 B1"), IOStandard("LVCMOS33")),
    ),
    ("clk48", 0, Pins("F4"), IOStandard("LVCMOS33"))
]
_io_hacker = [
    ("serial", 0,
        Subsignal("rx", Pins("C3")),
        Subsignal("tx", Pins("B3"), Misc("PULLUP")),
        IOStandard("LVCMOS33")
    ),
    ("usb", 0,
        Subsignal("d_p", Pins("A4")),
        Subsignal("d_n", Pins("A2")),
        Subsignal("pullup", Pins("D5")),
        IOStandard("LVCMOS33")
    ),
    ("led", 0,
        Subsignal("rgb0", Pins("A5"), IOStandard("LVCMOS33")),
        Subsignal("rgb1", Pins("B5"), IOStandard("LVCMOS33")),
        Subsignal("rgb2", Pins("C5"), IOStandard("LVCMOS33")),
    ),
    ("spiflash", 0,
        Subsignal("cs_n", Pins("C1"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("D1"), IOStandard("LVCMOS33")),
        Subsignal("miso", Pins("E1"), IOStandard("LVCMOS33")),
        Subsignal("mosi", Pins("F1"), IOStandard("LVCMOS33")),
        Subsignal("wp",   Pins("F2"), IOStandard("LVCMOS33")),
        Subsignal("hold", Pins("B1"), IOStandard("LVCMOS33")),
    ),
    ("spiflash4x", 0,
        Subsignal("cs_n", Pins("C1"), IOStandard("LVCMOS33")),
        Subsignal("clk",  Pins("D1"), IOStandard("LVCMOS33")),
        Subsignal("dq",   Pins("E1 F1 F2 B1"), IOStandard("LVCMOS33")),
    ),
    ("clk48", 0, Pins("F4"), IOStandard("LVCMOS33"))
]

_connectors = []

class _CRG(Module):
    def __init__(self, platform, use_pll):
        if use_pll:
            clk48_raw = platform.request("clk48")
            clk12_raw = Signal()
            clk48 = Signal()
            clk12 = Signal()

            # Divide clk48 down to clk12, to ensure they're synchronized.
            # By doing this, we avoid needing clock-domain crossing.
            clk12_counter = Signal(2)


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
            reset_delay = Signal(14, reset=4095)
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
        else:
            clk48_raw = platform.request("clk48")
            clk12_raw = Signal()
            clk48 = Signal()
            clk12 = Signal()

            self.clock_domains.cd_sys = ClockDomain()
            self.clock_domains.cd_usb_12 = ClockDomain()
            self.clock_domains.cd_usb_48 = ClockDomain()

            platform.add_period_constraint(self.cd_usb_48.clk, 1e9/48e6)
            platform.add_period_constraint(self.cd_sys.clk, 1e9/12e6)
            platform.add_period_constraint(self.cd_usb_12.clk, 1e9/12e6)
            platform.add_period_constraint(clk48, 1e9/48e6)

            self.reset = Signal()

            # POR reset logic- POR generated from sys clk, POR logic feeds sys clk
            # reset.
            self.clock_domains.cd_por = ClockDomain()
            reset_delay = Signal(13, reset=4095)
            self.comb += [
                self.cd_por.clk.eq(self.cd_sys.clk),
                self.cd_sys.rst.eq(reset_delay != 0),
                self.cd_usb_12.rst.eq(reset_delay != 0),
                # self.cd_usb_48.rst.eq(reset_delay != 0),
            ]

            self.specials += Instance(
                "SB_GB",
                i_USER_SIGNAL_TO_GLOBAL_BUFFER=clk48_raw,
                o_GLOBAL_BUFFER_OUTPUT=clk48,
            )
            self.comb += self.cd_usb_48.clk.eq(clk48)

            clk12_counter = Signal(2)
            self.sync.usb_48 += clk12_counter.eq(clk12_counter + 1)

            self.comb += clk12_raw.eq(clk12_counter[1])
            platform.add_period_constraint(clk12_raw, 1e9/12e6)
            self.specials += Instance(
                "SB_GB",
                i_USER_SIGNAL_TO_GLOBAL_BUFFER=clk12_raw,
                o_GLOBAL_BUFFER_OUTPUT=clk12,
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

class FirmwareROM(wishbone.SRAM):
    def __init__(self, size, filename):
        data = []
        with open(filename, 'rb') as inp:
            data = inp.read()
        wishbone.SRAM.__init__(self, size, read_only=True, init=data)

class Platform(LatticePlatform):
    default_clk_name = "clk48"
    default_clk_period = 20.833

    gateware_size = 0x20000

    def __init__(self, revision=None, toolchain="icestorm"):
        if revision == "evt":
            LatticePlatform.__init__(self, "ice40-up5k-sg48", _io_evt, _connectors, toolchain="icestorm")
        elif revision == "dvt":
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io_dvt, _connectors, toolchain="icestorm")
        elif revision == "hacker":
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io_hacker, _connectors, toolchain="icestorm")
        else:
            raise ValueError("Unrecognized reivsion: {}.  Known values: evt, dvt".format(revision))

    def create_programmer(self):
        raise ValueError("programming is not supported")

class SBLED(Module, AutoCSR):
    def __init__(self, pads):
        rgba_pwm = Signal(3)

        self.dat = CSRStorage(8)
        self.addr = CSRStorage(4)
        self.ctrl = CSRStorage(4)

        self.specials += Instance("SB_RGBA_DRV",
            i_CURREN = self.ctrl.storage[1],
            i_RGBLEDEN = self.ctrl.storage[2],
            i_RGB0PWM = rgba_pwm[0],
            i_RGB1PWM = rgba_pwm[1],
            i_RGB2PWM = rgba_pwm[2],
            o_RGB0 = pads.rgb0,
            o_RGB1 = pads.rgb1,
            o_RGB2 = pads.rgb2,
            p_CURRENT_MODE = "0b1",
            p_RGB0_CURRENT = "0b000011",
            p_RGB1_CURRENT = "0b000001",
            p_RGB2_CURRENT = "0b000011",
        )

        self.specials += Instance("SB_LEDDA_IP",
            i_LEDDCS = self.dat.re,
            i_LEDDCLK = ClockSignal(),
            i_LEDDDAT7 = self.dat.storage[7],
            i_LEDDDAT6 = self.dat.storage[6],
            i_LEDDDAT5 = self.dat.storage[5],
            i_LEDDDAT4 = self.dat.storage[4],
            i_LEDDDAT3 = self.dat.storage[3],
            i_LEDDDAT2 = self.dat.storage[2],
            i_LEDDDAT1 = self.dat.storage[1],
            i_LEDDDAT0 = self.dat.storage[0],
            i_LEDDADDR3 = self.addr.storage[3],
            i_LEDDADDR2 = self.addr.storage[2],
            i_LEDDADDR1 = self.addr.storage[1],
            i_LEDDADDR0 = self.addr.storage[0],
            i_LEDDDEN = self.dat.re,
            i_LEDDEXE = self.ctrl.storage[0],
            # o_LEDDON = led_is_on, # Indicates whether LED is on or not
            # i_LEDDRST = ResetSignal(), # This port doesn't actually exist
            o_PWMOUT0 = rgba_pwm[0], 
            o_PWMOUT1 = rgba_pwm[1], 
            o_PWMOUT2 = rgba_pwm[2],
            o_LEDDON = Signal(), 
        )

class SBWarmBoot(Module, AutoCSR):
    def __init__(self):
        self.ctrl = CSRStorage(size=8)
        do_reset = Signal()
        self.comb += [
            # "Reset Key" is 0xac (0b101011xx)
            do_reset.eq(self.ctrl.storage[2] & self.ctrl.storage[3] & ~self.ctrl.storage[4]
                      & self.ctrl.storage[5] & ~self.ctrl.storage[6] & self.ctrl.storage[7])
        ]
        self.specials += Instance("SB_WARMBOOT",
            i_S0   = self.ctrl.storage[0],
            i_S1   = self.ctrl.storage[1],
            i_BOOT = do_reset,
        )


class BBSpi(Module, AutoCSR):
    def __init__(self, platform, pads):
        self.reset = Signal()
        # self.rdata = Signal(32)
        # self.addr = Signal(24)
        # self.ready = Signal()
        # self.valid = Signal()

        # self.flash_csb = Signal()
        # self.flash_clk = Signal()

        # cfgreg_we = Signal(4)
        # cfgreg_di = Signal(32)
        # cfgreg_do = Signal(32)

        mosi_pad = TSTriple()
        miso_pad = TSTriple()
        cs_n_pad = TSTriple()
        clk_pad  = TSTriple()
        wp_pad   = TSTriple()
        hold_pad = TSTriple()

        self.do = CSRStorage(size=6)
        self.oe = CSRStorage(size=6)
        self.di = CSRStatus(size=6)
        # self.cfg = CSRStorage(size=8)

        # cfg_remapped = Cat(self.cfg.storage[0:7], Signal(7), self.cfg.storage[7])

        # self.comb += self.reset.eq(0)
        # self.comb += [
        #     cfgreg_di.eq(Cat(self.do.storage, Replicate(2, 0), # Attach "DO" to lower 6 bits
        #                      self.oe.storage, Replicate(4, 0), # Attach "OE" to bits 8-11
        #                      cfg_remapped)),
        #     cfgreg_we.eq(Cat(self.do.re, self.oe.re, self.cfg.re, self.cfg.re)),
        #     self.di.status.eq(cfgreg_do),
        #     clk_pad.oe.eq(~self.reset),
        #     cs_n_pad.oe.eq(~self.reset),
        # ]
        
        self.specials += mosi_pad.get_tristate(pads.mosi)
        self.specials += miso_pad.get_tristate(pads.miso)
        self.specials += cs_n_pad.get_tristate(pads.cs_n)
        self.specials += clk_pad.get_tristate(pads.clk)
        self.specials += wp_pad.get_tristate(pads.wp)
        self.specials += hold_pad.get_tristate(pads.hold)

        self.comb += [
            mosi_pad.oe.eq(self.oe.storage[0]),
            miso_pad.oe.eq(self.oe.storage[1]),
            wp_pad.oe.eq(self.oe.storage[2]),
            hold_pad.oe.eq(self.oe.storage[3]),
            clk_pad.oe.eq(self.oe.storage[4]),
            cs_n_pad.oe.eq(self.oe.storage[5]),

            mosi_pad.o.eq(self.do.storage[0]),
            miso_pad.o.eq(self.do.storage[1]),
            wp_pad.o.eq(self.do.storage[2]),
            hold_pad.o.eq(self.do.storage[3]),
            clk_pad.o.eq(self.do.storage[4]),
            cs_n_pad.o.eq(self.do.storage[5]),

            self.di.status.eq(Cat(mosi_pad.i, miso_pad.i, wp_pad.i, hold_pad.i, clk_pad.i, cs_n_pad.i)),
        ]
        # self.specials += Instance("spimemio", 
        #     o_flash_io0_oe = mosi_pad.oe,
        #     o_flash_io1_oe = miso_pad.oe,
        #     o_flash_io2_oe = wp_pad.oe,
        #     o_flash_io3_oe = hold_pad.oe,

        #     o_flash_io0_do = mosi_pad.o,
        #     o_flash_io1_do = miso_pad.o,
        #     o_flash_io2_do = wp_pad.o,
        #     o_flash_io3_do = hold_pad.o,

        #     i_flash_io0_di = mosi_pad.i,
        #     i_flash_io1_di = miso_pad.i,
        #     i_flash_io2_di = wp_pad.i,
        #     i_flash_io3_di = hold_pad.i,

        #     i_resetn = ResetSignal() | self.reset,
        #     i_clk = ClockSignal(),

        #     i_valid = self.valid,
        #     o_ready = self.ready,
        #     i_addr = self.addr,
        #     o_rdata = self.rdata,

	    #     i_cfgreg_we = cfgreg_we,
        #     i_cfgreg_di = cfgreg_di,
	    #     o_cfgreg_do = cfgreg_do,

        #     o_flash_csb = self.flash_csb,
        #     o_flash_clk = self.flash_clk,
        # )
        # platform.add_source("spimemio.v")

class BaseSoC(SoCCore):
    csr_peripherals = [
        "cpu_or_bridge",
        "usb",
        "bbspi",
        "reboot",
        "rgb",
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

    def __init__(self, platform, boot_source="rand", debug=False, bios_file=None, use_pll=True, **kwargs):
        # Disable integrated RAM as we'll add it later
        self.integrated_sram_size = 0

        clk_freq = int(12e6)
        self.submodules.crg = _CRG(platform, use_pll=use_pll)

        SoCCore.__init__(self, platform, clk_freq, integrated_sram_size=0, with_uart=False, **kwargs)

        if debug:
            self.cpu.use_external_variant("2-stage-1024-cache-debug.v")
            from litex.soc.cores.uart import UARTWishboneBridge
            self.register_mem("vexriscv_debug", 0xf00f0000, self.cpu.debug_bus, 0x10)
            self.submodules.uart_bridge = UARTWishboneBridge(platform.request("serial"), clk_freq, baudrate=115200)
            self.add_wb_master(self.uart_bridge.wishbone)
        else:
            self.cpu.use_external_variant("2-stage-1024-cache.v")

        # SPRAM- UP5K has single port RAM, might as well use it as SRAM to
        # free up scarce block RAM.
        spram_size = 128*1024
        self.submodules.spram = up5kspram.Up5kSPRAM(size=spram_size)
        self.register_mem("sram", 0x10000000, self.spram.bus, spram_size)

        if boot_source == "rand":
            kwargs['cpu_reset_address']=0
            bios_size = 0x2000
            self.submodules.random_rom = RandomFirmwareROM(bios_size)
            self.add_constant("ROM_DISABLE", 1)
            self.register_rom(self.random_rom.bus, bios_size)
        elif boot_source == "bios":
            kwargs['cpu_reset_address']=0
            if bios_file is None:
                bios_size = 0x2000
                self.add_memory_region("rom", kwargs['cpu_reset_address'], bios_size)
            else:
                bios_size = 0x2000
                self.submodules.firmware_rom = FirmwareROM(bios_size, bios_file)
                self.add_constant("ROM_DISABLE", 1)
                self.register_rom(self.firmware_rom.bus, bios_size)

        elif boot_source == "spi":
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

        # Add a simple bit-banged SPI Flash module
        spi_pads = platform.request("spiflash")
        self.submodules.bbspi = BBSpi(platform, spi_pads)

        self.submodules.reboot = SBWarmBoot()

        self.submodules.rgb = SBLED(platform.request("led"))

        # Add USB pads
        usb_pads = platform.request("usb")
        usb_iobuf = usbio.IoBuf(usb_pads.d_p, usb_pads.d_n, usb_pads.pullup)
        self.submodules.usb = epfifo.PerEndpointFifoInterface(usb_iobuf, endpoints=[EndpointType.BIDIR])
        # self.submodules.usb = epmem.MemInterface(usb_iobuf)
        # self.submodules.usb = unififo.UsbUniFifo(usb_iobuf)

        # Add "-relut -dffe_min_ce_use 4" to the synth_ice40 command.
        # The "-reult" adds an additional LUT pass to pack more stuff in,
        # and the "-dffe_min_ce_use 4" flag prevents Yosys from generating a
        # Clock Enable signal for a LUT that has fewer than 4 flip-flops.
        # This increases density, and lets us use the FPGA more efficiently.
        platform.toolchain.nextpnr_yosys_template[2] += " -dsp -relut -dffe_min_ce_use 5"

        # Disable final deep-sleep power down so firmware words are loaded
        # onto softcore's address bus.
        platform.toolchain.build_template[3] = "icepack -s {build_name}.txt {build_name}.bin"
        platform.toolchain.nextpnr_build_template[2] = "icepack -s {build_name}.txt {build_name}.bin"

        # # Add a "Multiboot" variant
        # platform.toolchain.nextpnr_build_template[3] = "icepack -s {build_name}.txt {build_name}-multi.bin"

def make_multiboot_header(filename, boot_offsets=[160]):
    """
    ICE40 allows you to program the SB_WARMBOOT state machine by adding the following
    values to the bitstream, before any given image:

    [7e aa 99 7e]       Sync Header
    [92 00 k0]          Boot mode (k = 1 for cold boot, 0 for warmboot)
    [44 03 o1 o2 o3]    Boot address
    [82 00 00]          Bank offset
    [01 08]             Reboot
    [...]               Padding (up to 32 bytes)

    Note that in ICE40, the second nybble indicates the number of remaining bytes
    (with the exception of the sync header).

    The above construct is repeated five times:

    INITIAL_BOOT        The image loaded at first boot
    BOOT_S00            The first image for SB_WARMBOOT
    BOOT_S01            The second image for SB_WARMBOOT
    BOOT_S10            The third image for SB_WARMBOOT
    BOOT_S11            The fourth image for SB_WARMBOOT
    """
    while len(boot_offsets) < 5:
        boot_offsets.append(boot_offsets[0])

    with open(filename, 'wb') as output:
        for offset in boot_offsets:
            # Sync Header
            output.write(bytes([0x7e, 0xaa, 0x99, 0x7e]))

            # Boot mode
            output.write(bytes([0x92, 0x00, 0x00]))

            # Boot address
            output.write(bytes([0x44, 0x03,
                    (offset >> 16) & 0xff,
                    (offset >> 8)  & 0xff,
                    (offset >> 0)  & 0xff]))

            # Bank offset
            output.write(bytes([0x82, 0x00, 0x00]))

            # Reboot command
            output.write(bytes([0x01, 0x08]))

            for x in range(17, 32):
                output.write(bytes([0]))

def main():
    make_multiboot_header("build/gateware/multiboot.bin", [160, 262144])
    parser = argparse.ArgumentParser(
        description="Build Fomu Main Gateware")
    parser.add_argument(
        "--boot-source", choices=["spi", "rand", "bios"], default="rand",
        help="where to have the CPU obtain its executable code from"
    )
    parser.add_argument(
        "--revision", choices=["dvt", "evt", "hacker"], required=True,
        help="build foboot for a particular hardware revision"
    )
    parser.add_argument(
        "--bios", help="use specified file as a BIOS, rather than building one"
    )
    parser.add_argument(
        "--with-debug", help="enable debug support", action="store_true"
    )
    parser.add_argument(
        "--no-pll", help="disable pll (possibly improving timing)", action="store_false"
    )
    parser.add_argument(
        "--export-random-rom-file", help="Generate a random ROM file and save it to a file"
    )
    args = parser.parse_args()

    if args.export_random_rom_file is not None:
        size = 0x2000
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
        seed = 1
        with open(args.export_random_rom_file, "w", newline="\n") as output:
            for d in range(int(size / 4)):
                seed = get_rand(seed)
                print("{:08x}".format(seed), file=output)
        return 0

    compile_software = False
    if args.boot_source == "bios" and args.bios is None:
        compile_software = True

    cpu_variant = "min"
    debug = False
    if args.with_debug:
        cpu_variant = "debug"
        debug = True

    os.environ["LITEX"] = "1" # Give our Makefile something to look for
    platform = Platform(revision=args.revision)
    soc = BaseSoC(platform, cpu_type="vexriscv", cpu_variant=cpu_variant,
                            debug=debug, boot_source=args.boot_source,
                            bios_file=args.bios, use_pll=args.no_pll)
    builder = Builder(soc, output_dir="build", csr_csv="test/csr.csv", compile_software=compile_software)
    if compile_software:
        builder.software_packages = [
            ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sw")))
        ]
    vns = builder.build()
    soc.do_exit(vns)

if __name__ == "__main__":
    main()
