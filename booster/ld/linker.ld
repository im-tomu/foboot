INCLUDE output_format.ld
ENTRY(_start)

__DYNAMIC = 0;

INCLUDE regions.ld

SECTIONS
{
	.startup :
	{
		. = ALIGN(4);
		*(.text.start)
		. = ALIGN(4);
		_estartup = .;
	} > rom

	.bss :
	{
		. = ALIGN(4);
		_fbss = .;
		*(.dynsbss)
		*(.sbss .sbss.* .gnu.linkonce.sb.*)
		*(.scommon)
		*(.dynbss)
		*(.bss .bss.* .gnu.linkonce.b.*)
		*(COMMON)
		. = ALIGN(4);
		_ebss = .;
		_end = .;
	} > sram

	.data : AT (ADDR(.startup) + SIZEOF (.startup))
	{
		_fdata = .;
		_ftext = .;
		*(.text .stub .text.* .gnu.linkonce.t.*)
		_etext = .;

		. = ALIGN(4);
		_frodata = .;
		*(.rodata .rodata.* .gnu.linkonce.r.*)
		*(.rodata1)
		*(.srodata)
		_erodata = .;

		. = ALIGN(4);
		*(.data .data.* .gnu.linkonce.d.*)
		*(.data1)
		_gp = ALIGN(16);
		*(.sdata .sdata.* .gnu.linkonce.s.* .sdata2 .sdata2.*)
		*(.ramtext .ramtext.*)
		_edata = ALIGN(16); /* Make sure _edata is >= _gp. */
	} > sram

  	booster_data = ADDR(.data) + SIZEOF(.data);
	booster_src = ADDR(.startup) + SIZEOF(.startup) + SIZEOF(.data);
}

PROVIDE(_fstack = ORIGIN(sram) + LENGTH(sram) - 4);
