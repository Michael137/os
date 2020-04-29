/* Constants for multiboot header */

.set ALIGN, 	1<<0				# align loaded modules on page boundaries
.set MEMINFO, 	1<<1				# provide memory map
.set FLAGS, 	ALIGN | MEMINFO		# Multiboot 'flag' field
.set MAGIC,		0x1BADB002			# 'magic number' for bootloader
.set CHECKSUM,	-(MAGIC + FLAGS)	# checksum of above constants (to verify multiboot)

/* Declare multiboot header that marks the program
   as a kernel. Magic values are documented in
   the multiboot standard. */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Stack must be 16-byte aligned according to the System V ABI standard.
   Stack grows downward on x86. */
.section .bootstrap_stack, "aw", @nobits
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

/* Preallocate pages. */
.section .bss, "aw", @nobits
	.align 4096
boot_page_directory:
	.skip 4096
boot_page_table1:
	.skip 4096
/* TODO: might need more page tables if kernel grows beyond 3 MiB */

/* The linker script specifies _start as the entry point to the
   kernel and the bootloader will jump to this position once the kernel
   has been loaded. */
.section .text
.global _start
.type _start, @function
_start:
	/* Here we are loaded into 32-bit protected mode on x86. I.e. interrupts
	   and paging are disabled. The processor state is as defined in the
	   multiboot standard. Kernel has complete power over the machine and
	   can only use funcionality it itself provides. */

	/* Physical addess of boot_page_table1 */
		movl $(boot_page_table1 - 0xC0000000), %edi

	/* First map address 0 */
		movl $0, %esi
	/* Then map 1023 pages. 1024th page is VGA text buffer */
		movl $1023, %ecx

1:
	/* Map kernel at virtual memory address 3 GiB */
		cmpl $(_kernel_start - 0xC0000000), %esi
		jl 2f
		cmpl $(_kernel_end - 0xC0000000), %esi
		jge 3f

	/* Map physical address as "present, writable". This maps .text and .rodata as writable */
		movl %esi, %edx
		orl $0x003, %edx
		movl %edx, (%edi)

2:
	/* Size of page is 4096 byte */
		addl $4096, %esi
	/* Size of entries in boot_page_table is 4 bytes (32-bit pointer) */
		addl $4, %edi
	/* Loop to next entry if we haven't finished */
		loop 1b

3:
	/* Map VGA video memory to 0xC03FF000 as "present, writable" */
		movl $(0x000B8000 | 0x003), boot_page_table1 - 0xC0000000 + 1023 * 4

	/* The page table is used at PD entry 0 (virtual from 0x0 to 0x3FFFFF) i.e., identity mapping the kernel, and PD
		entry 768 (virtual from 0xC0000000 to 0xC03FFFFF), i.e., mapping it in the higher half. CPU would page fault
		if kernel wasn't identity mapped here */

	/* Map page table to both virtual addresses 0x00000000 and 0xC00000000 */
		movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 0
		movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 768 * 4

	/* Set CR3 to address of boot_page_directory */
		movl $(boot_page_directory - 0xC0000000), %ecx
		movl %ecx, %cr3

	/* Enable paging */
		movl %cr0, %ecx
		orl $0x80010000, %ecx
		mov %ecx, %cr0

	/* Jump to higher half */
		lea 4f, %ecx
		jmp *%ecx

4:
	/* Unmap identity map */
		movl $0, boot_page_directory + 0

	/* Reload CR3 to force TLB flush such that changes take effect */
		movl %cr3, %ecx
		movl %ecx, %cr3

	/* Enable protected mode (https://wiki.osdev.org/Protected_Mode) */
		mov %cr0, %eax
		or $1, %al
		mov %eax, %cr0

	/* Here we set up the stack */
	   mov $stack_top, %esp

	/* Call global constructors */
		call _init

	/* Enter high-level kernel. ABI requires the stack is 16-byte
	   aligned at the time of the call instruction. */
	/* Transfer control to main kernel */
	   	call kernel_main

	/* Put computer into infinite loop as follows:
		1. Disable interrupts with cli (clear interrupt, enable in eflags)
		2. Wait for the next interrupt to arrive with hlt (halt instruction).
		   Since they are disabled, lock up the computer.
		3. Jump to the hlt instruction if it ever wakes up */

	/* Hang if kernel returns */
		cli
1:		hlt
		jmp 1b

/* Set size of _start symbol to the current location "." minus its start. */
/* Useful for debuggin */
.size _start, . - _start
