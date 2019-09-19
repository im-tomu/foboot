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
from migen.fhdl.bitcontainer import bits_for
from migen.fhdl.structure import ClockSignal, ResetSignal, Replicate, Cat
from migen.fhdl.decorators import ClockDomainsRenamer

from litex.build.lattice.platform import LatticePlatform
from litex.build.generic_platform import Pins, IOStandard, Misc, Subsignal
from litex.soc.integration import SoCCore
from litex.soc.integration.builder import Builder
from litex.soc.integration.soc_core import csr_map_update
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage, CSRField

from litex.soc.cores import up5kspram, spi_flash

from litex_boards.partner.targets.fomu import _CRG

from valentyusb import usbcore
from valentyusb.usbcore import io as usbio
from valentyusb.usbcore.cpu import epmem, unififo, epfifo, dummyusb, eptri
from valentyusb.usbcore.endpoint import EndpointType

import spibone
import lxsocdoc

import argparse
import os


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
    def __init__(self, revision=None, toolchain="icestorm"):
        self.revision = revision
        if revision == "evt":
            from litex_boards.partner.platforms.fomu_evt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-sg48", _io, _connectors, toolchain="icestorm")
        elif revision == "dvt":
            from litex_boards.partner.platforms.fomu_pvt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
        elif revision == "pvt":
            from litex_boards.partner.platforms.fomu_pvt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
        elif revision == "hacker":
            from litex_boards.partner.platforms.fomu_hacker import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
        else:
            raise ValueError("Unrecognized reivsion: {}.  Known values: evt, dvt, pvt, hacker".format(revision))

    def create_programmer(self):
        raise ValueError("programming is not supported")

class SBLED(Module, AutoCSR):
    def __init__(self, revision, pads):
        rgba_pwm = Signal(3)

        self.dat = CSRStorage(8, description="""This is the value for the `SB_LEDDA_IP.DAT` register.  It is
                            directly written into the `SB_LEDDA_IP` hardware block, so you should
                            refer to http://www.latticesemi.com/view_document?document_id=50668.  The
                            contents of this register are written to the address specified in `ADDR`
                            immediately upon writing this register.""")
        self.addr = CSRStorage(4, description="""This register is directly connected to `SB_LEDDA_IP.ADDR`.
                            This register controls the address that is updated whenever `DAT` is written.
                            Writing to this register has no immediate effect -- data isn't written until
                            the `DAT` register is written.""")
        self.ctrl = CSRStorage(fields=[
            CSRField("exe", description="Connected to `SB_LEDDA_IP.LEDDEXE`.  Set this to `1` to enable the fading pattern."),
            CSRField("curren", description="Connected to `SB_RGBA_DRV.CURREN`.  Set this to `1` to enable the current source."),
            CSRField("rgbleden", description="Connected to `SB_RGBA_DRV.RGBLEDEN`.  Set this to `1` to enable the RGB PWM control logic."),
            CSRField("rraw", description="Set this to `1` to enable raw control of the red LED via the `RAW.R` register."),
            CSRField("graw", description="Set this to `1` to enable raw control of the green LED via the `RAW.G` register."),
            CSRField("braw", description="Set this to `1` to enable raw control of the blue LED via the `RAW.B` register."),
        ], description="Control logic for the RGB LED and LEDDA hardware PWM LED block.")
        self.raw = CSRStorage(fields=[
            CSRField("r", description="Raw value for the red LED when `CTRL.RRAW` is `1`."),
            CSRField("g", description="Raw value for the green LED when `CTRL.GRAW` is `1`."),
            CSRField("b", description="Raw value for the blue LED when `CTRL.BRAW` is `1`."),
        ], description="""Normally the hardware `SB_LEDDA_IP` block controls the brightness of the LED,
                creating a gentle fading pattern.  However, by setting the appropriate bit in `CTRL`,
                it is possible to manually control the three individual LEDs.""")

        ledd_value = Signal(3)
        if revision == "pvt" or revision == "evt" or revision == "dvt":
            self.comb += [
                If(self.ctrl.storage[3], rgba_pwm[1].eq(self.raw.storage[0])).Else(rgba_pwm[1].eq(ledd_value[0])),
                If(self.ctrl.storage[4], rgba_pwm[0].eq(self.raw.storage[1])).Else(rgba_pwm[0].eq(ledd_value[1])),
                If(self.ctrl.storage[5], rgba_pwm[2].eq(self.raw.storage[2])).Else(rgba_pwm[2].eq(ledd_value[2])),
            ]
        elif revision == "hacker":
            self.comb += [
                If(self.ctrl.storage[3], rgba_pwm[2].eq(self.raw.storage[0])).Else(rgba_pwm[2].eq(ledd_value[0])),
                If(self.ctrl.storage[4], rgba_pwm[1].eq(self.raw.storage[1])).Else(rgba_pwm[1].eq(ledd_value[1])),
                If(self.ctrl.storage[5], rgba_pwm[0].eq(self.raw.storage[2])).Else(rgba_pwm[0].eq(ledd_value[2])),
            ]
        else:
            self.comb += [
                If(self.ctrl.storage[3], rgba_pwm[0].eq(self.raw.storage[0])).Else(rgba_pwm[0].eq(ledd_value[0])),
                If(self.ctrl.storage[4], rgba_pwm[1].eq(self.raw.storage[1])).Else(rgba_pwm[1].eq(ledd_value[1])),
                If(self.ctrl.storage[5], rgba_pwm[2].eq(self.raw.storage[2])).Else(rgba_pwm[2].eq(ledd_value[2])),
            ]

        self.specials += Instance("SB_RGBA_DRV",
            i_CURREN = self.ctrl.storage[1],
            i_RGBLEDEN = self.ctrl.storage[2],
            i_RGB0PWM = rgba_pwm[0],
            i_RGB1PWM = rgba_pwm[1],
            i_RGB2PWM = rgba_pwm[2],
            o_RGB0 = pads.r,
            o_RGB1 = pads.g,
            o_RGB2 = pads.b,
            p_CURRENT_MODE = "0b1",
            p_RGB0_CURRENT = "0b000011",
            p_RGB1_CURRENT = "0b000011",
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
            o_PWMOUT0 = ledd_value[0],
            o_PWMOUT1 = ledd_value[1],
            o_PWMOUT2 = ledd_value[2],
            o_LEDDON = Signal(),
        )


class SBWarmBoot(Module, AutoCSR):
    def __init__(self, parent):
        self.ctrl = CSRStorage(fields=[
            CSRField("image", size=2, description="Which image to reboot to.  `SB_WARMBOOT` supports four images that are configured at startup.  The bootloader is image 0, so set these bits to 0 to reboot back into the bootloader."),
            CSRField("key", size=6, description="A reboot key used to prevent accidental reboots.  Set this to 0b101011.")
        ], description="Support rebooting the FPGA.  You can select which of the four images to reboot to, just be sure to OR the image number with 0xac.  For example, to reboot to the bootloader (image 0), write `0xac` to this register.")
        self.addr = CSRStorage(size=32, description="""This sets the reset vector for the VexRiscv.
                                            This address will be used whenever the CPU is reset, for example
                                            through a debug bridge.  You should update this address whenever
                                            you load a new program, to enable the debugger to run `mon reset`""")
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
        parent.config["BITSTREAM_SYNC_HEADER1"] = 0x7e99aa7e
        parent.config["BITSTREAM_SYNC_HEADER2"] = 0x7eaa997e


class TouchPads(Module, AutoCSR):
    touch_device = [
        ("touch_pads", 0,
            Subsignal("t1", Pins("touch_pins:0")),
            Subsignal("t2", Pins("touch_pins:1")),
            Subsignal("t3", Pins("touch_pins:2")),
            Subsignal("t4", Pins("touch_pins:3")),
        )
    ]
    def __init__(self, pads):
        touch1 = TSTriple()
        touch2 = TSTriple()
        touch3 = TSTriple()
        touch4 = TSTriple()
        self.specials += touch1.get_tristate(pads.t1)
        self.specials += touch2.get_tristate(pads.t2)
        self.specials += touch3.get_tristate(pads.t3)
        self.specials += touch4.get_tristate(pads.t4)

        self.o  = CSRStorage(fields=[
            CSRField("o", 4, description="Output values for pads 1-4")
        ])
        self.oe = CSRStorage(fields=[
            CSRField("oe", 4, description="Output enable control for pads 1-4")
        ])
        self.i  = CSRStatus(fields=[
            CSRField("i", 4, description="Input value for pads 1-4")
        ])

        self.comb += [
            touch1.o.eq(self.o.storage[0]),
            touch2.o.eq(self.o.storage[1]),
            touch3.o.eq(self.o.storage[2]),
            touch4.o.eq(self.o.storage[3]),

            touch1.oe.eq(self.oe.storage[0]),
            touch2.oe.eq(self.oe.storage[1]),
            touch3.oe.eq(self.oe.storage[2]),
            touch4.oe.eq(self.oe.storage[3]),

            self.i.status.eq(Cat(touch1.i, touch2.i, touch3.i, touch4.i))
        ]


class PicoRVSpi(Module, AutoCSR):
    def __init__(self, platform, pads, size=2*1024*1024):
        self.size = size

        self.bus = bus = wishbone.Interface()

        self.reset = Signal()

        self.cfg1 = CSRStorage(fields=[
            CSRField("bb_out", size=4, description="Output bits in bit-bang mode"),
            CSRField("bb_clk", description="Serial clock line in bit-bang mode"),
            CSRField("bb_cs", description="Chip select line in bit-bang mode"),
        ])
        self.cfg2 = CSRStorage(fields=[
            CSRField("bb_oe", size=4, description="Output Enable bits in bit-bang mode"),
        ])
        self.cfg3 = CSRStorage(fields=[
            CSRField("rlat", size=4, description="Read latency/dummy cycle count"),
            CSRField("crm", description="Continuous Read Mode enable bit"),
            CSRField("qspi", description="Quad-SPI enable bit"),
            CSRField("ddr", description="Double Data Rate enable bit"),
        ])
        self.cfg4 = CSRStorage(fields=[
            CSRField("memio", offset=7, reset=1, description="Enable memory-mapped mode (set to 0 to enable bit-bang mode)")
        ])

        self.stat1 = CSRStatus(fields=[
            CSRField("bb_in", size=4, description="Input bits in bit-bang mode"),
        ])
        self.stat2 = CSRStatus(1, fields=[], description="Reserved")
        self.stat3 = CSRStatus(1, fields=[], description="Reserved")
        self.stat4 = CSRStatus(1, fields=[], description="Reserved")

        cfg = Signal(32)
        cfg_we = Signal(4)
        cfg_out = Signal(32)
        self.comb += [
            cfg.eq(Cat(self.cfg1.storage, self.cfg2.storage, self.cfg3.storage, self.cfg4.storage)),
            cfg_we.eq(Cat(self.cfg1.re, self.cfg2.re, self.cfg3.re, self.cfg4.re)),
            self.stat1.status.eq(cfg_out[0:8]),
            self.stat2.status.eq(cfg_out[8:16]),
            self.stat3.status.eq(cfg_out[16:24]),
            self.stat4.status.eq(cfg_out[24:32]),
        ]

        mosi_pad = TSTriple()
        miso_pad = TSTriple()
        cs_n_pad = TSTriple()
        clk_pad  = TSTriple()
        wp_pad   = TSTriple()
        hold_pad = TSTriple()
        self.specials += mosi_pad.get_tristate(pads.mosi)
        self.specials += miso_pad.get_tristate(pads.miso)
        self.specials += cs_n_pad.get_tristate(pads.cs_n)
        self.specials += clk_pad.get_tristate(pads.clk)
        self.specials += wp_pad.get_tristate(pads.wp)
        self.specials += hold_pad.get_tristate(pads.hold)

        reset = Signal()
        self.comb += [
            reset.eq(ResetSignal() | self.reset),
            cs_n_pad.oe.eq(~reset),
            clk_pad.oe.eq(~reset),
        ]

        flash_addr = Signal(24)
        # size/4 because data bus is 32 bits wide, -1 for base 0
        mem_bits = bits_for(int(size/4)-1)
        pad = Signal(2)
        self.comb += flash_addr.eq(Cat(pad, bus.adr[0:mem_bits-1]))

        read_active = Signal()
        spi_ready = Signal()
        self.sync += [
            If(bus.stb & bus.cyc & ~read_active,
                read_active.eq(1),
                bus.ack.eq(0),
            )
            .Elif(read_active & spi_ready,
                read_active.eq(0),
                bus.ack.eq(1),
            )
            .Else(
                bus.ack.eq(0),
                read_active.eq(0),
            )
        ]

        o_rdata = Signal(32)
        self.comb += bus.dat_r.eq(o_rdata)

        self.specials += Instance("spimemio",
            o_flash_io0_oe = mosi_pad.oe,
            o_flash_io1_oe = miso_pad.oe,
            o_flash_io2_oe = wp_pad.oe,
            o_flash_io3_oe = hold_pad.oe,

            o_flash_io0_do = mosi_pad.o,
            o_flash_io1_do = miso_pad.o,
            o_flash_io2_do = wp_pad.o,
            o_flash_io3_do = hold_pad.o,
            o_flash_csb    = cs_n_pad.o,
            o_flash_clk    = clk_pad.o,

            i_flash_io0_di = mosi_pad.i,
            i_flash_io1_di = miso_pad.i,
            i_flash_io2_di = wp_pad.i,
            i_flash_io3_di = hold_pad.i,

            i_resetn = ~reset,
            i_clk = ClockSignal(),

            i_valid = bus.stb & bus.cyc,
            o_ready = spi_ready,
            i_addr  = flash_addr,
            o_rdata = o_rdata,

            i_cfgreg_we = cfg_we,
            i_cfgreg_di = cfg,
            o_cfgreg_do = cfg_out,
        )
        platform.add_source("rtl/spimemio.v")

class Version(Module, AutoCSR):
    def __init__(self, model):
        def makeint(i, base=10):
            try:
                return int(i, base=base)
            except:
                return 0
        def get_gitver():
            import subprocess
            def decode_version(v):
                version = v.split(".")
                major = 0
                minor = 0
                rev = 0
                if len(version) >= 3:
                    rev = makeint(version[2])
                if len(version) >= 2:
                    minor = makeint(version[1])
                if len(version) >= 1:
                    major = makeint(version[0])
                return (major, minor, rev)
            git_rev_cmd = subprocess.Popen(["git", "describe", "--tags", "--dirty=+"],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
            (git_stdout, _) = git_rev_cmd.communicate()
            if git_rev_cmd.wait() != 0:
                print('unable to get git version')
                return
            raw_git_rev = git_stdout.decode().strip()

            dirty = False
            if raw_git_rev[-1] == "+":
                raw_git_rev = raw_git_rev[:-1]
                dirty = True

            parts = raw_git_rev.split("-")
            major = 0
            minor = 0
            rev = 0
            gitrev = 0
            gitextra = 0

            if len(parts) >= 3:
                if parts[0].startswith("v"):
                    version = parts[0]
                    if version.startswith("v"):
                        version = parts[0][1:]
                    (major, minor, rev) = decode_version(version)
                gitextra = makeint(parts[1])
                if parts[2].startswith("g"):
                    gitrev = makeint(parts[2][1:], base=16)
            elif len(parts) >= 2:
                if parts[1].startswith("g"):
                    gitrev = makeint(parts[1][1:], base=16)
                version = parts[0]
                if version.startswith("v"):
                    version = parts[0][1:]
                (major, minor, rev) = decode_version(version)
            elif len(parts) >= 1:
                version = parts[0]
                if version.startswith("v"):
                    version = parts[0][1:]
                (major, minor, rev) = decode_version(version)

            return (major, minor, rev, gitrev, gitextra, dirty)

        self.major = CSRStatus(8, description="Major git tag version.  For example, if this repository was built from git tag `v1.9.2`, then this value would be `1`.")
        self.minor = CSRStatus(8, description="Minor git tag version.  For example, if this repository was built from git tag `v1.9.2`, then this value would be `9`.")
        self.revision = CSRStatus(8, description="Revision git tag version.  For example, if this repository was built from git tag `v1.9.2`, then this value would be `2`.")
        self.gitrev = CSRStatus(32, description="First 32-bits of the git revision.  This should be enough to check out the exact git version used to build this firmware.")
        self.gitextra = CSRStatus(10, description="The number of additional commits beyond the git tag.  For example, if this value is `1`, then the repository this was built from has one additional commit beyond the tag indicated in `MAJOR`, `MINOR`, and `REVISION`.")
        self.dirty = CSRStatus(fields=[
            CSRField("dirty", description="Set to `1` if this device was built from a git repo with uncommitted modifications.")
        ])
        self.model = CSRStatus(fields=[
            CSRField("model", size=8, description="Contains information on which model device this was built for.", values=[
                ("0x45", "E", "Fomu EVT"),
                ("0x44", "D", "Fomu DVT"),
                ("0x50", "P", "Fomu PVT (production)"),
                ("0x48", "H", "Fomu Hacker"),
                ("0x3f", "?", "Unknown model"),
            ])
        ])

        (major, minor, rev, gitrev, gitextra, dirty) = get_gitver()
        self.comb += [
            self.major.status.eq(major),
            self.minor.status.eq(minor),
            self.revision.status.eq(rev),
            self.gitrev.status.eq(gitrev),
            self.gitextra.status.eq(gitextra),
            self.dirty.status.eq(dirty),
        ]
        if model == "evt":
            self.comb += self.model.status.eq(0x45) # 'E'
        elif model == "dvt":
            self.comb += self.model.status.eq(0x44) # 'D'
        elif model == "pvt":
            self.comb += self.model.status.eq(0x50) # 'P'
        elif model == "hacker":
            self.comb += self.model.status.eq(0x48) # 'H'
        else:
            self.comb += self.model.status.eq(0x3f) # '?'


class BaseSoC(SoCCore):
    SoCCore.csr_map = {
        "ctrl":           0,  # provided by default (optional)
        "crg":            1,  # user
        "uart_phy":       2,  # provided by default (optional)
        "uart":           3,  # provided by default (optional)
        "identifier_mem": 4,  # provided by default (optional)
        "timer0":         5,  # provided by default (optional)
        "cpu_or_bridge":  8,
        "usb":            9,
        "picorvspi":      10,
        "touch":          11,
        "reboot":         12,
        "rgb":            13,
        "version":        14,
        "lxspi":          15,
    }

    SoCCore.mem_map = {
        "rom":      0x00000000,  # (default shadow @0x80000000)
        "sram":     0x10000000,  # (default shadow @0xa0000000)
        "spiflash": 0x20000000,  # (default shadow @0xa0000000)
        "main_ram": 0x40000000,  # (default shadow @0xc0000000)
        "csr":      0x60000000,  # (default shadow @0xe0000000)
    }

    interrupt_map = {
        "usb": 3,
    }
    interrupt_map.update(SoCCore.interrupt_map)

    def __init__(self, platform, boot_source="rand",
                 debug=None, bios_file=None,
                 use_dsp=False, placer=None, output_dir="build",
                 pnr_seed=0,
                 **kwargs):
        # Disable integrated RAM as we'll add it later
        self.integrated_sram_size = 0

        self.output_dir = output_dir

        clk_freq = int(12e6)
        self.submodules.crg = _CRG(platform)

        SoCCore.__init__(self, platform, clk_freq, integrated_sram_size=0, with_uart=False, **kwargs)

        usb_debug = False
        if debug is not None:
            if debug == "uart":
                from litex.soc.cores.uart import UARTWishboneBridge
                self.submodules.uart_bridge = UARTWishboneBridge(platform.request("serial"), clk_freq, baudrate=115200)
                self.add_wb_master(self.uart_bridge.wishbone)
            elif debug == "usb":
                usb_debug = True
            if hasattr(self, "cpu"):
                self.cpu.use_external_variant("rtl/2-stage-1024-cache-debug.v")
                self.copy_memory_file("2-stage-1024-cache-debug.v_toplevel_RegFilePlugin_regFile.bin")
                os.path.join(output_dir, "gateware")
                self.register_mem("vexriscv_debug", 0xf00f0000, self.cpu.debug_bus, 0x100)
        else:
            if hasattr(self, "cpu"):
                self.cpu.use_external_variant("rtl/2-stage-1024-cache.v")
                self.copy_memory_file("2-stage-1024-cache.v_toplevel_RegFilePlugin_regFile.bin")

        # # Add SPI Wishbone bridge
        # spi_pads = platform.request("spidebug")
        # self.submodules.spibone = ClockDomainsRenamer("usb_12")(spibone.SpiWishboneBridge(spi_pads, wires=4))
        # self.add_wb_master(self.spibone.wishbone)

        # SPRAM- UP5K has single port RAM, might as well use it as SRAM to
        # free up scarce block RAM.
        spram_size = 128*1024
        self.submodules.spram = up5kspram.Up5kSPRAM(size=spram_size)
        self.register_mem("sram", self.mem_map["sram"], self.spram.bus, spram_size)

        if boot_source == "rand":
            kwargs['cpu_reset_address']=0
            bios_size = 0x2000
            self.submodules.random_rom = RandomFirmwareROM(bios_size)
            self.add_constant("ROM_DISABLE", 1)
            self.register_rom(self.random_rom.bus, bios_size)
        elif boot_source == "bios":
            kwargs['cpu_reset_address'] = 0
            if bios_file is None:
                self.integrated_rom_size = bios_size = 0x2000
                self.submodules.rom = wishbone.SRAM(bios_size, read_only=True, init=[])
                self.register_rom(self.rom.bus, bios_size)
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
        # spi_pads = platform.request("spiflash4x")
        # if spi_pads is not None:
        #     self.submodules.lxspi = spi_flash.SpiFlashDualQuad(spi_pads)
        # else:
        #     spi_pads = platform.request("spiflash")
        #     self.submodules.lxspi = spi_flash.SpiFlashSingle(spi_pads)
        # self.register_mem("spiflash", self.mem_map["spiflash"],
        #     self.lxspi.bus, size=2 * 1024 * 1024) # NOTE: EVT is 16 * 1024 * 1024

        self.submodules.picorvspi = PicoRVSpi(platform, platform.request("spiflash"))
        self.register_mem("spiflash", self.mem_map["spiflash"],
            self.picorvspi.bus, size=self.picorvspi.size)

        self.submodules.reboot = SBWarmBoot(self)
        if hasattr(self, "cpu"):
            self.cpu.cpu_params.update(
                i_externalResetVector=self.reboot.addr.storage,
            )

        self.submodules.rgb = SBLED(platform.revision, platform.request("rgb_led"))
        self.submodules.version = Version(platform.revision)

        # Add USB pads
        usb_pads = platform.request("usb")
        usb_iobuf = usbio.IoBuf(usb_pads.d_p, usb_pads.d_n, usb_pads.pullup)
        if hasattr(self, "cpu"):
            self.submodules.usb = eptri.TriEndpointInterface(usb_iobuf, debug=usb_debug)
            # self.submodules.usb = epfifo.PerEndpointFifoInterface(usb_iobuf, debug=usb_debug)
        else:
            self.submodules.usb = dummyusb.DummyUsb(usb_iobuf, debug=usb_debug)

        if usb_debug:
            self.add_wb_master(self.usb.debug_bridge.wishbone)
        # For the EVT board, ensure the pulldown pin is tristated as an input
        if hasattr(usb_pads, "pulldown"):
            pulldown = TSTriple()
            self.specials += pulldown.get_tristate(usb_pads.pulldown)
            self.comb += pulldown.oe.eq(0)

        # Add GPIO pads for the touch buttons
        platform.add_extension(TouchPads.touch_device)
        self.submodules.touch = TouchPads(platform.request("touch_pads"))

        # Add "-relut -dffe_min_ce_use 4" to the synth_ice40 command.
        # The "-reult" adds an additional LUT pass to pack more stuff in,
        # and the "-dffe_min_ce_use 4" flag prevents Yosys from generating a
        # Clock Enable signal for a LUT that has fewer than 4 flip-flops.
        # This increases density, and lets us use the FPGA more efficiently.
        platform.toolchain.nextpnr_yosys_template[2] += " -relut -dffe_min_ce_use 4"
        if use_dsp:
            platform.toolchain.nextpnr_yosys_template[2] += " -dsp"

        # Disable final deep-sleep power down so firmware words are loaded
        # onto softcore's address bus.
        platform.toolchain.build_template[3] = "icepack -s {build_name}.txt {build_name}.bin"
        platform.toolchain.nextpnr_build_template[2] = "icepack -s {build_name}.txt {build_name}.bin"

        # Allow us to set the nextpnr seed
        platform.toolchain.nextpnr_build_template[1] += " --seed " + str(pnr_seed)

        if placer is not None:
            platform.toolchain.nextpnr_build_template[1] += " --placer {}".format(placer)

    def copy_memory_file(self, src):
        import os
        from shutil import copyfile
        if not os.path.exists(self.output_dir):
            os.mkdir(self.output_dir)
        if not os.path.exists(os.path.join(self.output_dir, "gateware")):
            os.mkdir(os.path.join(self.output_dir, "gateware"))
        copyfile(os.path.join("rtl", src), os.path.join(self.output_dir, "gateware", src))

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
    parser = argparse.ArgumentParser(
        description="Build Fomu Main Gateware")
    parser.add_argument(
        "--boot-source", choices=["spi", "rand", "bios"], default="bios",
        help="where to have the CPU obtain its executable code from"
    )
    parser.add_argument(
        "--revision", choices=["evt", "dvt", "pvt", "hacker"], required=True,
        help="build foboot for a particular hardware revision"
    )
    parser.add_argument(
        "--bios", help="use specified file as a BIOS, rather than building one"
    )
    parser.add_argument(
        "--with-debug", help="enable debug support", choices=["usb", "uart", None]
    )
    parser.add_argument(
        "--with-dsp", help="use dsp inference in yosys (not all yosys builds have -dsp)", action="store_true"
    )
    parser.add_argument(
        "--no-cpu", help="disable cpu generation for debugging purposes", action="store_true"
    )
    parser.add_argument(
        "--placer", choices=["sa", "heap"], help="which placer to use in nextpnr"
    )
    parser.add_argument(
        "--seed", default=0, help="seed to use in nextpnr"
    )
    parser.add_argument(
        "--export-random-rom-file", help="Generate a random ROM file and save it to a file"
    )
    args = parser.parse_args()

    output_dir = 'build'

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

    cpu_type = "vexriscv"
    cpu_variant = "min"
    if args.with_debug:
        cpu_variant = cpu_variant + "+debug"

    if args.no_cpu:
        cpu_type = None
        cpu_variant = None

    os.environ["LITEX"] = "1" # Give our Makefile something to look for
    platform = Platform(revision=args.revision)
    soc = BaseSoC(platform, cpu_type=cpu_type, cpu_variant=cpu_variant,
                            debug=args.with_debug, boot_source=args.boot_source,
                            bios_file=args.bios,
                            use_dsp=args.with_dsp, placer=args.placer,
                            pnr_seed=args.seed,
                            output_dir=output_dir)
    builder = Builder(soc, output_dir=output_dir, csr_csv="test/csr.csv", compile_software=False, compile_gateware=False)
    if compile_software:
        builder.software_packages = [
            ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sw")))
        ]
    vns = builder.build()
    soc.do_exit(vns)
    lxsocdoc.generate_docs(soc, "../doc/soc/source/")

    make_multiboot_header(os.path.join(output_dir, "gateware", "multiboot-header.bin"), [
        160,
        160,
        157696,
        262144,
        262144 + 32768,
    ])

    with open(os.path.join(output_dir, 'gateware', 'multiboot-header.bin'), 'rb') as multiboot_header_file:
        multiboot_header = multiboot_header_file.read()
        with open(os.path.join(output_dir, 'gateware', 'top.bin'), 'rb') as top_file:
            top = top_file.read()
            with open(os.path.join(output_dir, 'gateware', 'top-multiboot.bin'), 'wb') as top_multiboot_file:
                top_multiboot_file.write(multiboot_header)
                top_multiboot_file.write(top)

    print(
"""Foboot build complete.  Output files:
    {}/gateware/top.bin             Bitstream file.  Load this onto the FPGA for testing.
    {}/gateware/top-multiboot.bin   Multiboot-enabled bitstream file.  Flash this onto FPGA ROM.
    {}/gateware/top.v               Source Verilog file.  Useful for debugging issues.
    {}/software/include/generated/  Directory with header files for API access.
    {}/software/bios/bios.elf       ELF file for debugging bios.
""".format(output_dir, output_dir, output_dir, output_dir, output_dir))

if __name__ == "__main__":
    main()
