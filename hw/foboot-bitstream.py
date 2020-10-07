#!/usr/bin/env python3
# This variable defines all the external programs that this module
# relies on.  lxbuildenv reads this variable in order to ensure
# the build will finish without exiting due to missing third-party
# programs.
LX_DEPENDENCIES = ["riscv", "icestorm", "yosys", "nextpnr-ice40"]

# Import lxbuildenv to integrate the deps/ directory
import lxbuildenv

# Disable pylint's E1101, which breaks completely on migen
#pylint:disable=E1101

#from migen import *
from migen import Module, Signal, Instance, ClockDomain, If
from migen.fhdl.specials import TSTriple
from migen.fhdl.decorators import ClockDomainsRenamer
from migen.genlib.cdc import AsyncResetSynchronizer

from litex.build.lattice.platform import LatticePlatform
from litex.build.generic_platform import Pins, Subsignal
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.integration.soc_core import SoCCore
from litex.soc.cores.cpu import CPUNone
from litex.soc.integration.builder import Builder
from litex.soc.interconnect import wishbone

from litex.soc.cores import up5kspram, spi_flash

from valentyusb.usbcore import io as usbio
from valentyusb.usbcore.cpu import epmem, unififo, epfifo, dummyusb, eptri
from valentyusb.usbcore.endpoint import EndpointType

import litex.soc.doc as lxsocdoc
import spibone

import argparse
import os

from rtl.version import Version
from rtl.romgen import RandomFirmwareROM, FirmwareROM
from rtl.fomutouch import TouchPads
from rtl.sbled import SBLED
from rtl.sbwarmboot import SBWarmBoot
from rtl.messible import Messible

class Platform(LatticePlatform):
    def __init__(self, revision=None, toolchain="icestorm"):
        self.revision = revision
        if revision == "evt":
            from litex_boards.platforms.fomu_evt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-sg48", _io, _connectors, toolchain="icestorm")
            self.spi_size = 16 * 1024 * 1024
            self.spi_dummy = 6
        elif revision == "dvt":
            from litex_boards.platforms.fomu_pvt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
            self.spi_size = 2 * 1024 * 1024
            self.spi_dummy = 6
        elif revision == "pvt":
            from litex_boards.platforms.fomu_pvt import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
            self.spi_size = 2 * 1024 * 1024
            self.spi_dummy = 6
        elif revision == "hacker":
            from litex_boards.platforms.fomu_hacker import _io, _connectors
            LatticePlatform.__init__(self, "ice40-up5k-uwg30", _io, _connectors, toolchain="icestorm")
            self.spi_size = 2 * 1024 * 1024
            self.spi_dummy = 4
        else:
            raise ValueError("Unrecognized revision: {}.  Known values: evt, dvt, pvt, hacker".format(revision))

    def create_programmer(self):
        raise ValueError("programming is not supported")


class _CRG(Module, AutoDoc):
    """Fomu Clock Resource Generator

    Fomu is a USB device, which means it must have a 12 MHz clock.  Valentyusb
    oversamples the clock by 4x, which drives the requirement for a 48 MHz clock.
    The ICE40UP5k is a relatively low speed grade of FPGA that is incapable of
    running the entire design at 48 MHz, so the majority of the logic is placed
    in the 12 MHz domain while only critical USB logic is placed in the fast
    48 MHz domain.

    Fomu has a 48 MHz crystal on it, which provides the raw clock input.  This
    signal is fed through the ICE40 PLL in order to divide it down into a 12 MHz
    signal and keep the clocks within 1ns of phase.  Earlier designs used a simple
    flop, however this proved unreliable when the FPGA became very full.

    The following clock domains are available on this design:

    +---------+------------+---------------------------------+
    | Name    | Frequency  | Description                     |
    +=========+============+=================================+
    | usb_48  | 48 MHz     | Raw USB signals and pulse logic |
    +---------+------------+---------------------------------+
    | usb_12  | 12 MHz     | USB control logic               |
    +---------+------------+---------------------------------+
    | sys     | 12 MHz     | System CPU and wishbone bus     |
    +---------+------------+---------------------------------+
    """
    def __init__(self, platform):
        clk48_raw = platform.request("clk48")
        clk12 = Signal()

        reset_delay = Signal(12, reset=4095)
        self.clock_domains.cd_por = ClockDomain()
        self.reset = Signal()

        self.clock_domains.cd_sys = ClockDomain()
        self.clock_domains.cd_usb_12 = ClockDomain()
        self.clock_domains.cd_usb_48 = ClockDomain()

        platform.add_period_constraint(self.cd_usb_48.clk, 1e9/48e6)
        platform.add_period_constraint(self.cd_sys.clk, 1e9/12e6)
        platform.add_period_constraint(self.cd_usb_12.clk, 1e9/12e6)
        platform.add_period_constraint(clk48_raw, 1e9/48e6)

        # POR reset logic- POR generated from sys clk, POR logic feeds sys clk
        # reset.
        self.comb += [
            self.cd_por.clk.eq(self.cd_sys.clk),
            self.cd_sys.rst.eq(reset_delay != 0),
            self.cd_usb_12.rst.eq(reset_delay != 0),
        ]

        # POR reset logic- POR generated from sys clk, POR logic feeds sys clk
        # reset.
        self.comb += [
            self.cd_usb_48.rst.eq(reset_delay != 0),
        ]

        self.comb += self.cd_usb_48.clk.eq(clk48_raw)

        self.specials += Instance(
            "SB_PLL40_CORE",
            # Parameters
            p_DIVR = 0,
            p_DIVF = 15,
            p_DIVQ = 5,
            p_FILTER_RANGE = 1,
            p_FEEDBACK_PATH = "SIMPLE",
            p_DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED",
            p_FDA_FEEDBACK = 15,
            p_DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED",
            p_FDA_RELATIVE = 0,
            p_SHIFTREG_DIV_MODE = 1,
            p_PLLOUT_SELECT = "GENCLK_HALF",
            p_ENABLE_ICEGATE = 0,
            # IO
            i_REFERENCECLK = clk48_raw,
            o_PLLOUTCORE = clk12,
            # o_PLLOUTGLOBAL = clk12,
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


class BaseSoC(SoCCore, AutoDoc):
    """Fomu Bootloader and Base SoC

    Fomu is an FPGA that fits in your USB port.  This reference manual
    documents the basic SoC that runs the bootloader, and that can be
    reused to run your own RISC-V programs.

    This reference manual only describes a particular version of the SoC.
    The register sets described here are guaranteed to be available
    with a given ``major version``, but are not guaranteed to be available on
    any other version.  Naturally, you are free to create your own SoC
    that does not provide these hardware blocks. To see what the version of the
    bitstream you're running, check the ``VERSION`` registers.
    """

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
        "messible":       16,
    }

    SoCCore.mem_map = {
        "rom":              0x00000000,  # (default shadow @0x80000000)
        "sram":             0x10000000,  # (default shadow @0xa0000000)
        "spiflash":         0x20000000,  # (default shadow @0xa0000000)
        "main_ram":         0x40000000,  # (default shadow @0xc0000000)
        "csr":              0xe0000000,  # (default shadow @0xe0000000)
        "vexriscv_debug":   0xf00f0000,
    }

    interrupt_map = {
        "timer0": 2,
        "usb": 3,
    }
    interrupt_map.update(SoCCore.interrupt_map)

    def __init__(self, platform, boot_source="rand",
                 debug=None, bios_file=None,
                 use_dsp=False, placer="heap", output_dir="build",
                 pnr_seed=0,
                 warmboot_offsets=None,
                 **kwargs):
        # Disable integrated RAM as we'll add it later
        self.integrated_sram_size = 0

        self.output_dir = output_dir

        clk_freq = int(12e6)
        self.submodules.crg = _CRG(platform)

        SoCCore.__init__(self, platform, clk_freq, integrated_sram_size=0, with_uart=False, csr_data_width=32, **kwargs)

        usb_debug = False
        if debug is not None:
            if debug == "uart":
                from litex.soc.cores.uart import UARTWishboneBridge
                self.submodules.uart_bridge = UARTWishboneBridge(platform.request("serial"), clk_freq, baudrate=115200)
                self.add_wb_master(self.uart_bridge.wishbone)
            elif debug == "usb":
                usb_debug = True
            elif debug == "spi":
                import spibone
                # Add SPI Wishbone bridge
                debug_device = [
                    ("spidebug", 0,
                        Subsignal("mosi", Pins("dbg:0")),
                        Subsignal("miso", Pins("dbg:1")),
                        Subsignal("clk",  Pins("dbg:2")),
                        Subsignal("cs_n", Pins("dbg:3")),
                    )
                ]
                platform.add_extension(debug_device)
                spi_pads = platform.request("spidebug")
                self.submodules.spibone = ClockDomainsRenamer("usb_12")(spibone.SpiWishboneBridge(spi_pads, wires=4))
                self.add_wb_master(self.spibone.wishbone)
            if hasattr(self, "cpu") and not isinstance(self.cpu, CPUNone):
                self.cpu.use_external_variant("rtl/VexRiscv_Fomu_Debug.v")
                os.path.join(output_dir, "gateware")
                self.register_mem("vexriscv_debug", 0xf00f0000, self.cpu.debug_bus, 0x100)
        else:
            if hasattr(self, "cpu") and not isinstance(self.cpu, CPUNone):
                self.cpu.use_external_variant("rtl/VexRiscv_Fomu.v")

        # SPRAM- UP5K has single port RAM, might as well use it as SRAM to
        # free up scarce block RAM.
        spram_size = 128*1024
        self.submodules.spram = up5kspram.Up5kSPRAM(size=spram_size)
        self.register_mem("sram", self.mem_map["sram"], self.spram.bus, spram_size)

        # Add a Messible for device->host communications
        self.submodules.messible = Messible()

        if boot_source == "rand":
            kwargs['cpu_reset_address'] = 0
            bios_size = 0x2000
            self.submodules.random_rom = RandomFirmwareROM(bios_size)
            self.add_constant("ROM_DISABLE", 1)
            self.register_rom(self.random_rom.bus, bios_size)
        elif boot_source == "bios":
            kwargs['cpu_reset_address'] = 0
            if hasattr(self, "cpu") and not isinstance(self.cpu, CPUNone):
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
            kwargs['cpu_reset_address'] = 0
            self.integrated_rom_size = bios_size = 0x2000
            gateware_size = 0x1a000
            self.flash_boot_address = self.mem_map["spiflash"] + gateware_size
            self.submodules.rom = wishbone.SRAM(bios_size, read_only=True, init=[])
            self.register_rom(self.rom.bus, bios_size)
        else:
            raise ValueError("unrecognized boot_source: {}".format(boot_source))

        # The litex SPI module supports memory-mapped reads, as well as a bit-banged mode
        # for doing writes.
        spi_pads = platform.request("spiflash4x")
        self.submodules.lxspi = spi_flash.SpiFlashDualQuad(spi_pads, dummy=platform.spi_dummy, endianness="little")
        self.register_mem("spiflash", self.mem_map["spiflash"], self.lxspi.bus, size=platform.spi_size)

        # Add USB pads, as well as the appropriate USB controller.  If no CPU is
        # present, use the DummyUsb controller.
        usb_pads = platform.request("usb")
        usb_iobuf = usbio.IoBuf(usb_pads.d_p, usb_pads.d_n, usb_pads.pullup)
        if hasattr(self, "cpu") and not isinstance(self.cpu, CPUNone):
            self.submodules.usb = eptri.TriEndpointInterface(usb_iobuf, debug=usb_debug)
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

        # Allow the user to reboot the ICE40.  Additionally, connect the CPU
        # RESET line to a register that can be modified, to allow for
        # us to debug programs even during reset.
        self.submodules.reboot = SBWarmBoot(self, warmboot_offsets)
        if hasattr(self, "cpu") and not isinstance(self.cpu, CPUNone):
            self.cpu.cpu_params.update(
                i_externalResetVector=self.reboot.addr.storage,
            )

        self.submodules.rgb = SBLED(platform.revision, platform.request("rgb_led"))
        self.submodules.version = Version(platform.revision, self, pnr_seed, models=[
                ("0x45", "E", "Fomu EVT"),
                ("0x44", "D", "Fomu DVT"),
                ("0x50", "P", "Fomu PVT (production)"),
                ("0x48", "H", "Fomu Hacker"),
                ("0x3f", "?", "Unknown model"),
            ])

        # Override default LiteX's yosys/build templates
        assert hasattr(platform.toolchain, "yosys_template")
        assert hasattr(platform.toolchain, "build_template")
        platform.toolchain.yosys_template = [
            "{read_files}",
            "attrmap -tocase keep -imap keep=\"true\" keep=1 -imap keep=\"false\" keep=0 -remove keep=0",
            "synth_ice40 -json {build_name}.json -top {build_name}",
        ]
        platform.toolchain.build_template = [
            "yosys -q -l {build_name}.rpt {build_name}.ys",
            "nextpnr-ice40 --json {build_name}.json --pcf {build_name}.pcf --asc {build_name}.txt \
            --pre-pack {build_name}_pre_pack.py --{architecture} --package {package}",
            "icepack {build_name}.txt {build_name}.bin"
        ]

        # Add "-relut -dffe_min_ce_use 4" to the synth_ice40 command.
        # The "-reult" adds an additional LUT pass to pack more stuff in,
        # and the "-dffe_min_ce_use 4" flag prevents Yosys from generating a
        # Clock Enable signal for a LUT that has fewer than 4 flip-flops.
        # This increases density, and lets us use the FPGA more efficiently.
        platform.toolchain.yosys_template[2] += " -relut -abc2 -dffe_min_ce_use 4 -relut"
        if use_dsp:
            platform.toolchain.yosys_template[2] += " -dsp"

        # Disable final deep-sleep power down so firmware words are loaded
        # onto softcore's address bus.
        platform.toolchain.build_template[2] = "icepack -s {build_name}.txt {build_name}.bin"

        # Allow us to set the nextpnr seed
        platform.toolchain.build_template[1] += " --seed " + str(pnr_seed)

        if placer is not None:
            platform.toolchain.build_template[1] += " --placer {}".format(placer)

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
        "--document-only", default=False, action="store_true",
        help="Don't build gateware or software, only build documentation"
    )
    parser.add_argument(
        "--revision", choices=["evt", "dvt", "pvt", "hacker"], required=True,
        help="build foboot for a particular hardware revision"
    )
    parser.add_argument(
        "--bios", help="use specified file as a BIOS, rather than building one"
    )
    parser.add_argument(
        "--with-debug", help="enable debug support", choices=["usb", "uart", "spi", None]
    )
    parser.add_argument(
        "--with-dsp", help="use dsp inference in yosys (not all yosys builds have -dsp)", action="store_true"
    )
    parser.add_argument(
        "--no-cpu", help="disable cpu generation for debugging purposes", action="store_true"
    )
    parser.add_argument(
        "--placer", choices=["sa", "heap"], default="heap", help="which placer to use in nextpnr"
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
    if (args.boot_source == "bios" or args.boot_source == "spi") and args.bios is None:
        compile_software = True

    cpu_type = "vexriscv"
    cpu_variant = "minimal"
    if args.with_debug:
        cpu_variant = cpu_variant + "+debug"

    if args.no_cpu:
        cpu_type = None
        cpu_variant = None

    compile_gateware = True
    if args.document_only:
        compile_gateware = False
        compile_software = False

    warmboot_offsets = [
        160,
        160,
        157696,
        262144,
        262144 + 32768,
    ]

    os.environ["LITEX"] = "1" # Give our Makefile something to look for
    platform = Platform(revision=args.revision)
    soc = BaseSoC(platform, cpu_type=cpu_type, cpu_variant=cpu_variant,
                            debug=args.with_debug, boot_source=args.boot_source,
                            bios_file=args.bios,
                            use_dsp=args.with_dsp, placer=args.placer,
                            pnr_seed=int(args.seed),
                            output_dir=output_dir,
                            warmboot_offsets=warmboot_offsets[1:])
    builder = Builder(soc, output_dir=output_dir, csr_csv="build/csr.csv", csr_svd="build/soc.svd",
                      compile_software=compile_software, compile_gateware=compile_gateware)
    if compile_software:
        builder.software_packages = [
            ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sw")))
        ]
    vns = builder.build()
    soc.do_exit(vns)
    lxsocdoc.generate_docs(soc, "build/documentation/", project_name="Fomu Bootloader", author="Sean Cross")

    if not args.document_only:
        make_multiboot_header(os.path.join(output_dir, "gateware", "multiboot-header.bin"),
                            warmboot_offsets)

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
