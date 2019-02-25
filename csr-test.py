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

from migen import Module, Signal, Instance, ClockDomain, If, run_simulation
from migen.genlib.resetsync import AsyncResetSynchronizer
from litex.build.lattice.platform import LatticePlatform
from litex.build.generic_platform import Pins, IOStandard, Misc, Subsignal
from litex.soc.integration import SoCCore
from litex.soc.integration.builder import Builder
from litex.soc.integration.soc_core import csr_map_update
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import CSR, CSRStorage, AutoCSR

def csr_test(dut):
    for i in range(20):
        counter = yield dut.counter
        # test_value = yield dut.test_value.w
        (test_value) = yield from dut.test_value.read()
        print("CSR value: {} / {}".format(counter, test_value))
        # yield from CSRStorage.update_csrs()
        yield

class TestCSR(Module, AutoCSR):
    def __init__(self):
        # self.counter = Signal(8)
        # self.test_value = CSR(8)
        # self.result = Signal(8)
        # self.read_result = Signal()
        # self.sync += [
        #     self.counter.eq(self.counter+1),
        #     self.test_value.w.eq(self.counter),
        #     self.result.eq(self.test_value.r),
        #     self.read_result.eq(self.test_value.re),
        # ]
        self.counter = Signal(8)
        self.test_value = CSRStorage(8, write_from_dev=True)
        self.result = Signal(8)
        self.result_re = Signal()
        self.sync += [
            self.counter.eq(self.counter+1),
            self.test_value.we.eq(1),
            self.test_value.dat_w.eq(self.counter),
            self.result.eq(self.test_value.storage),
            self.result_re.eq(self.test_value.re),
        ]

def main():
    dut = TestCSR()
    for x in dir(dut):
        print("x: {}".format(x))
    for csr in dut.get_csrs():
        print("csr: {}".format(csr))
        if isinstance(csr, CSRStorage) and hasattr(csr, "dat_w"):
            print("Adding CSRStorage patch")
            dut.sync += [
                If(csr.we,
                    csr.storage.eq(csr.dat_w),
                    csr.re.eq(1),
                ).Else(
                    csr.re.eq(0),
                )
            ]
    run_simulation(dut, csr_test(dut), vcd_name="csr-test.vcd")

if __name__ == "__main__":
    main()
