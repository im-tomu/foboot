from migen import Module
from migen.genlib import fifo
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import AutoCSR, CSRStatus, CSRStorage, CSRField

class Messible(Module, AutoCSR, AutoDoc):
    """Messaging-style Ansible"""
    def __init__(self):
        self.submodules.fifo = f = fifo.SyncFIFOBuffered(width=8, depth=64)
        in_reg = CSRStorage(8, name="in", description="""
                    Write half of the FIFO to send data out the Messible.
                    Writing to this register advances the write pointer automatically.""")
        out_reg = CSRStatus(8, name="out", description="""
                    Read half of the FIFO to receive data on the Messible.
                    Reading from this register advances the read pointer automatically.""")

        self.__setattr__("in", in_reg)
        self.__setattr__("out", out_reg)
        self.status = status = CSRStatus(fields=[
            CSRField("full", description="``0`` if more data can fit into the IN FIFO."),
            CSRField("have", description="``1`` if data can be read from the OUT FIFO."),
        ])

        self.intro = ModuleDoc("""
                Messible: An Ansible for Messages

                An Ansible is a system for instant communication across vast distances, from
                a small portable device to a huge terminal far away.  A Messible is a message-
                passing system from embedded devices to a host system.  You can use it to get
                very simple printf()-style support over a debug channel.

                The Messible assumes the host has a way to peek into the device's memory space.
                This is the case with the Wishbone bridge, which allows both the device and
                the host to access the same memory.

                At its core, a Messible is a FIFO.  As long as the ``STATUS.FULL`` bit is ``0``, the
                device can write data into the Messible by writing into the ``IN``.  However, if this
                value is ``1``, you need to decide if you want to wait for it to empty (if the other
                side is just slow), or if you want to drop the message.

                From the host side, you need to read ``STATUS.HAVE`` to see if there is data
                in the FIFO.  If there is, read ``OUT`` to get the most recent byte, which automatically
                advances the ``READ`` pointer.
                """)

        self.comb += [
            f.din.eq(in_reg.storage),
            f.we.eq(in_reg.re),
            out_reg.status.eq(f.dout),
            f.re.eq(out_reg.we),
            status.fields.full.eq(~f.writable),
            status.fields.have.eq(f.readable),
        ]
