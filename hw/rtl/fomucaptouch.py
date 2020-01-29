from migen import Module, TSTriple, Cat, Signal, If, wrap
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage, CSRField
from litex.soc.integration.doc import ModuleDoc
from litex.build.generic_platform import Pins, Subsignal
from litex.soc.interconnect import csr_eventmanager as ev

class CapTouchPads(Module, AutoCSR):
    touch_device = [
        ("touch_pads", 0,
            Subsignal("t1", Pins("touch_pins:0")),
            Subsignal("t2", Pins("touch_pins:1")),
            Subsignal("t3", Pins("touch_pins:2")),
            Subsignal("t4", Pins("touch_pins:3")),
        )
    ]
    def __init__(self, pads, debugging=False):
        self.intro = ModuleDoc("""Fomu Touchpads

        Fomu has four single-ended exposed pads on its side.  These pads are designed
        to be connected to some captouch block, or driven in a resistive touch mode
        in order to get simple touchpad support.

        This block attempts to implement capacative touch, while still providing
        backwards-compatibility with the original Fomu touchpad interface.

        More research will need to be done in order to determine sane defaults for the
        trigger levels.
        """)

        cap_signal_size = 8

        touch1 = TSTriple()
        touch2 = TSTriple()
        touch3 = TSTriple()
        touch4 = TSTriple()
        self.specials += touch1.get_tristate(pads.t1)
        self.specials += touch2.get_tristate(pads.t2)
        self.specials += touch3.get_tristate(pads.t3)
        self.specials += touch4.get_tristate(pads.t4)
        ios = [touch1, touch2, touch3, touch4]

        self.o      = CSRStorage(4, description="Output values for pads 1-4", fields=[
            CSRField("o1", description="Output value for pad 1"),
            CSRField("o2", description="Output value for pad 2"),
            CSRField("o3", description="Output value for pad 3"),
            CSRField("o4", description="Output value for pad 4"),
        ])
        self.oe     = CSRStorage(4, description="Output enable control for pads 1-4", fields=[
            CSRField("oe1", description="Output Enable value for pad 1"),
            CSRField("oe2", description="Output Enable value for pad 2"),
            CSRField("oe3", description="Output Enable value for pad 3"),
            CSRField("oe4", description="Output Enable value for pad 4"),
        ])
        self.i      = CSRStatus(4, description="Input value for pads 1-4", fields=[
            CSRField("i1", description="Input value for pad 1"),
            CSRField("i2", description="Input value for pad 2"),
            CSRField("i3", description="Input value for pad 3"),
            CSRField("i4", description="Input value for pad 4"),
        ])
        self.capen  = CSRStorage(4, description="Enable captouch for pads 1-4", fields=[
            CSRField("t1", description="Enable captouch for pad 1"),
            CSRField("t2", description="Enable captouch for pad 2"),
            CSRField("t3", description="Enable captouch for pad 3"),
            CSRField("t4", description="Enable captouch for pad 4"),
        ])

        cper = 524288
        cap_count_len = 20
        if debugging:
            cap_count_len = 32
            self.cper   = CSRStorage(cap_count_len, description="""The number of clock cycles for one sample period

            The hardware will count how many times the touchpad discharges within this sample
            period and reflect that value in the corresponding `count` register.""", reset=524288)
            cper = self.cper.storage

        self.cstat  = CSRStatus(4, description="Current status of the captouch buttons", fields=[
            CSRField("s1", description="State of pad 1"),
            CSRField("s2", description="State of pad 2"),
            CSRField("s3", description="State of pad 3"),
            CSRField("s4", description="State of pad 4"),
        ])

        cpress = 0x0a
        crel = 0x03
        if debugging:
            self.cpress = CSRStorage(cap_signal_size, reset=0x0a, description="Count threshold for triggering a ``press`` event")
            cpress = self.cpress.storage
            self.crel   = CSRStorage(cap_signal_size, reset=0x03, description="Count threshold for triggering a ``release`` event")
            crel = self.crel.storage
        if debugging:
            self.c1     = CSRStatus(cap_signal_size, description="Count of events for pad 1")
            self.c2     = CSRStatus(cap_signal_size, description="Count of events for pad 2")
            self.c3     = CSRStatus(cap_signal_size, description="Count of events for pad 3")
            self.c4     = CSRStatus(cap_signal_size, description="Count of events for pad 4")

        cap_count = Signal(cap_count_len)
        cap1_count = Signal(cap_signal_size)
        cap2_count = Signal(cap_signal_size)
        cap3_count = Signal(cap_signal_size)
        cap4_count = Signal(cap_signal_size)

        self.submodules.ev = ev.EventManager()
        self.ev.submodules.touch = ev.EventSourcePulse(name="touch", description="""
            Indicates a touch event such as a "press" or "release" has occurred.""")
        self.ev.finalize()

        ar = []
        syn = []
        cmb = []
        for num, pad in enumerate(ios, start=1):
            print("touch{}".format(num))
            if debugging:
                exec("ar.append(self.c{}.status.eq(cap{}_count))".format(num, num))
            exec("ar.append(cap{}_count.eq(0))".format(num))

            # Implement a schmitt trigger in Verilog
            # 1: Value is 1 and count > crel OR value is 0 and count > cpress
            # 0: Value is 1 and count < crel OR value is 0 and count < cpress
            exec("""ar.append(self.cstat.fields.s{}.eq(
                    (self.cstat.fields.s{} & wrap(cap{}_count > crel)) |
                    (~self.cstat.fields.s{} & wrap(cap{}_count > cpress))))""".format(num, num, num, num, num))

            exec("cmb.append(pad.o.eq(self.o.fields.o{} | self.capen.fields.t{}))".format(num, num))
            exec("cmb.append(self.i.fields.i{}.eq(pad.i))".format(num))
            exec("syn.append(cap{}_count.eq(cap{}_count + (self.capen.fields.t{} & ~pad.i)))".format(num, num, num))
            exec("syn.append(pad.oe.eq(self.oe.fields.oe{} | (self.capen.fields.t{} & ~pad.i)))".format(num, num))

        # This is used to trigger an interrupt when this value changes
        last_stat = Signal(4)

        self.sync += [
            self.ev.touch.trigger.eq(0),

            last_stat.eq(self.cstat.status),
            self.ev.touch.trigger.eq(self.cstat.status != last_stat),

            *syn,

            # Perform a captouch tick
            If(cap_count > 0,
                cap_count.eq(cap_count - 1),
            ).Else(
                cap_count.eq(cper),
                *ar,
            ),
        ]

        self.comb += [
            *cmb,
        ]
