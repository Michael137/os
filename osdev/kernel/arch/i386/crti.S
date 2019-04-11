# Set up stack as usual with function calls
# 1. push stack base address (to which we later return to in crtn.S)
# 2. create stack frame

.section .init
.global _init
.type _init, @function
_init:
	push %ebp
	movl %esp, %ebp
	/* gcc puts contents of crtbegin.o's .init section here */

.section .fini
.global _fini
.type _fini, @function
_fini:
	push %ebp
	movl %esp, %ebp
	/* gcc puts contents of crtbegin.o's .fini section here */
