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
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

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

	/* Here we set up the stack */
	   mov $stack_top, %esp

		# TODO: could call global constructors here

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
