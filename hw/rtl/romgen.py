from litex.soc.interconnect import wishbone

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

class JumpToAddressROM(wishbone.SRAM):
    def __init__(self, size, addr):
        data = [
            0x00000537 | ((addr & 0xfffff000) << 0 ), # lui   a0,%hi(addr)
            0x00052503 | ((addr & 0x00000fff) << 20), # lw    a0,%lo(addr)(a0)
            0x000500e7,                               # jalr  a0
        ]
        wishbone.SRAM.__init__(self, size, read_only=True, init=data)
