from migen import Module, Signal, If, Instance
from litex.soc.integration.doc import ModuleDoc
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage, CSRField
import litex.soc.doc as lxsocdoc

class SBWarmBoot(Module, AutoCSR):
    def __init__(self, parent, offsets=None):

        table = ""
        if offsets is not None:
            arr = [["Image", "Offset"]]
            for i,offset in enumerate(offsets):
                arr.append([str(i), str(offset)])
            table = "\nYou can use this block to reboot into one of these four addresses:\n\n" \
                  + lxsocdoc.rst.make_table(arr)
        self.intro = ModuleDoc("""FPGA Reboot Interface

            This module provides the ability to reboot the FPGA.  It is based on the
            ``SB_WARMBOOT`` primitive built in to the FPGA.

            When power is applied to the FPGA, it reads configuration data from the
            onboard flash chip.  This contains reboot offsets for four images.  It then
            booted from the first image, but kept note of the other addresses.
            {}""".format(table))
        self.ctrl = CSRStorage(fields=[
            CSRField("image", size=2, description="""
                        Which image to reboot to.  ``SB_WARMBOOT`` supports four images that
                        are configured at FPGA startup.  The bootloader is image 0, so set
                        these bits to 0 to reboot back into the bootloader.
                        """),
            CSRField("key", size=6, description="""
                        A reboot key used to prevent accidental reboots when writing to random
                        areas of memory.  To initiate a reboot, set this to ``0b101011``.""")
        ], description="""
                Provides support for rebooting the FPGA.  You can select which of the four images
                to reboot to, just be sure to OR the image number with ``0xac``.  For example,
                to reboot to the bootloader (image 0), write ``0xac``` to this register."""
        )
        self.addr = CSRStorage(size=32, description="""
                This sets the reset vector for the VexRiscv.  This address will be used whenever
                the CPU is reset, for example through a debug bridge.  You should update this
                address whenever you load a new program, to enable the debugger to run ``mon reset``
                """
            )
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
