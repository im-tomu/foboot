from migen import Module, Signal, If, Instance, ClockSignal
from litex.soc.integration.doc import ModuleDoc
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage, CSRField

class SBLED(Module, AutoCSR):
    def __init__(self, revision, pads):
        rgba_pwm = Signal(3)

        self.intro = ModuleDoc("""RGB LED Controller

                The ICE40 contains two different RGB LED control devices.  The first is a
                constant-current LED source, which is fixed to deliver 4 mA to each of the
                three LEDs.  This block is called ``SB_RGBA_DRV``.

                The other is used for creating interesting fading effects, particularly
                for "breathing" effects used to indicate a given state.  This block is called
                ``SB_LEDDA_IP``.  This block feeds directly into ``SB_RGBA_DRV``.

                The RGB LED controller available on this device allows for control of these
                two LED control devices.  Additionally, it is possible to disable ``SB_LEDDA_IP``
                and directly control the individual LEDs.
                """)

        self.dat = CSRStorage(8, description="""
                            This is the value for the ``SB_LEDDA_IP.DAT`` register.  It is directly
                            written into the ``SB_LEDDA_IP`` hardware block, so you should
                            refer to http://www.latticesemi.com/view_document?document_id=50668.
                            The contents of this register are written to the address specified in
                            ``ADDR`` immediately upon writing this register.""")
        self.addr = CSRStorage(4, description="""
                            This register is directly connected to ``SB_LEDDA_IP.ADDR``.  This
                            register controls the address that is updated whenever ``DAT`` is
                            written.  Writing to this register has no immediate effect -- data
                            isn't written until the ``DAT`` register is written.""")
        self.ctrl = CSRStorage(fields=[
            CSRField("exe", description="Connected to ``SB_LEDDA_IP.LEDDEXE``.  Set this to ``1`` to enable the fading pattern."),
            CSRField("curren", description="Connected to ``SB_RGBA_DRV.CURREN``.  Set this to ``1`` to enable the current source."),
            CSRField("rgbleden", description="Connected to ``SB_RGBA_DRV.RGBLEDEN``.  Set this to ``1`` to enable the RGB PWM control logic."),
            CSRField("rraw", description="Set this to ``1`` to enable raw control of the red LED via the ``RAW.R`` register."),
            CSRField("graw", description="Set this to ``1`` to enable raw control of the green LED via the ``RAW.G`` register."),
            CSRField("braw", description="Set this to ``1`` to enable raw control of the blue LED via the ``RAW.B`` register."),
        ], description="Control logic for the RGB LED and LEDDA hardware PWM LED block.")
        self.raw = CSRStorage(fields=[
            CSRField("r", description="Raw value for the red LED when ``CTRL.RRAW`` is ``1``."),
            CSRField("g", description="Raw value for the green LED when ``CTRL.GRAW`` is ``1``."),
            CSRField("b", description="Raw value for the blue LED when ``CTRL.BRAW`` is ``1``."),
        ], description="""
                Normally the hardware ``SB_LEDDA_IP`` block controls the brightness of the LED,
                creating a gentle fading pattern.  However, by setting the appropriate bit in ``CTRL``,
                it is possible to manually control the three individual LEDs.""")

        ledd_value = Signal(3)
        if revision == "pvt" or revision == "dvt":
            self.comb += [
                If(self.ctrl.storage[3], rgba_pwm[1].eq(self.raw.storage[0])).Else(rgba_pwm[1].eq(ledd_value[0])),
                If(self.ctrl.storage[4], rgba_pwm[0].eq(self.raw.storage[1])).Else(rgba_pwm[0].eq(ledd_value[1])),
                If(self.ctrl.storage[5], rgba_pwm[2].eq(self.raw.storage[2])).Else(rgba_pwm[2].eq(ledd_value[2])),
            ]
        elif revision == "evt":
            self.comb += [
                If(self.ctrl.storage[3], rgba_pwm[1].eq(self.raw.storage[0])).Else(rgba_pwm[1].eq(ledd_value[0])),
                If(self.ctrl.storage[4], rgba_pwm[2].eq(self.raw.storage[1])).Else(rgba_pwm[2].eq(ledd_value[1])),
                If(self.ctrl.storage[5], rgba_pwm[0].eq(self.raw.storage[2])).Else(rgba_pwm[0].eq(ledd_value[2])),
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
