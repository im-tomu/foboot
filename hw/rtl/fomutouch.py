from migen import Module, TSTriple, Cat
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage
from litex.soc.integration.doc import ModuleDoc
from litex.build.generic_platform import Pins, Subsignal

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
        self.intro = ModuleDoc("""Fomu Touchpads

        Fomu has four single-ended exposed pads on its side.  These pads are designed
        to be connected to some captouch block, or driven in a resistive touch mode
        in order to get simple touchpad support.

        This block simply provides CPU-controlled GPIO support for this block.  It has
        three registers which control the In, Out, and Output Enable functionality of
        each of these pins.
        """)
        touch1 = TSTriple()
        touch2 = TSTriple()
        touch3 = TSTriple()
        touch4 = TSTriple()
        self.specials += touch1.get_tristate(pads.t1)
        self.specials += touch2.get_tristate(pads.t2)
        self.specials += touch3.get_tristate(pads.t3)
        self.specials += touch4.get_tristate(pads.t4)

        self.o  = CSRStorage(4, description="Output values for pads 1-4")
        self.oe = CSRStorage(4, description="Output enable control for pads 1-4")
        self.i  = CSRStatus(4, description="Input value for pads 1-4")

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
