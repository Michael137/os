/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
ENTRY(_start)
 
/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* Kernel lives at 3 GB + 1 MB in the VAS which will be mapped to
 	 * 1 MB in the PAS. */
	. = 0xC0100000;

	/* These labels can be used in code files */
	kernel_virtual_start = .;
	kernel_physical_start = . - 0xC0000000;

	/* NOTE: we page-align the sections */
	.text ALIGN(4K) : AT (ADDR (.text) - 0xC0000000)
	{
		*(.multiboot)
		*(.text)
	}
	/* Read-only data. */
	.rodata ALIGN(4K) : AT (ADDR (.rodata) - 0xC0000000)
	{
		*(.rodata)
	}
	/* Read-write data (initialized) */
	.data ALIGN(4K) : AT (ADDR (.data) - 0xC0000000)
	{
		*(.data)
	}
	/* Read-write data (uninitialized) and stack */
	.bss ALIGN(4K) : AT (ADDR (.bss) - 0xC0000000)
	{
		*(COMMON)
		*(.bss)
		*(.bootstrap_stack)
	}

	kernel_virtual_end = .;
	kernel_physical_end = . - 0xC0000000;
 
	/* The compiler may produce other sections, by default it will put them in
	   a segment with the same name. Simply add stuff here as needed. */
}
