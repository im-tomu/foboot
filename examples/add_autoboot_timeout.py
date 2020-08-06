#!/usr/bin/env python3
import argparse
import sys

parser = argparse.ArgumentParser(description="Add auto-boot timeout to bitstream")
parser.add_argument("infile", type=str)
parser.add_argument("outfile", type=str)
parser.add_argument("--timeout", type=int, default=5)
args = parser.parse_args()

COMMENT_START = 0x00FF
COMMENT_END = 0xFF00
MAGIC_WORD = 0x4A6DE3AC
BITSTREAM_SYNC_HEADER1 = 2123999870
BITSTREAM_SYNC_HEADER2 = 2125109630
ENDIANNESS = "little"


def to_bytes(v, n=4):
    return v.to_bytes(n, byteorder=ENDIANNESS, signed=False)


def from_bytes(v):
    return int.from_bytes(v, byteorder=ENDIANNESS)


if args.timeout < 1 or args.timeout > 255:
    sys.stderr.write("Error: Pick a timeout between 1s and 255s")
    sys.exit(1)

with open(args.infile, "rb") as infile:
    with open(args.outfile, "wb") as outfile:
        first_word = from_bytes(infile.read(4))
        if (
            first_word != BITSTREAM_SYNC_HEADER1
            and first_word != BITSTREAM_SYNC_HEADER2
            and first_word & 0xFFFF != COMMENT_START
        ):
            sys.stderr.write("Error: File does not appear to be a bitstream")
            sys.stderr.write(
                "(for RISC-V programs use the AUTOBOOT_TIMEOUT make option)"
            )
            sys.exit(1)
        outfile.write(to_bytes(COMMENT_START))
        outfile.write(to_bytes(MAGIC_WORD))
        outfile.write(to_bytes(args.timeout))
        if first_word & 0xFFFF == COMMENT_START:  # there already is a comments section
            outfile.write(to_bytes(0, n=2))  # make sure alignment is correct
            outfile.write(to_bytes(first_word >> 16, n=2))
        else:
            outfile.write(to_bytes(COMMENT_END))
        outfile.write(infile.read())
