.section .text
_entry:
	# Set up stack s.t. sp = stack0 + (hartid * 4096)
	# I.e., each CPU gets 4 KB stack
	la sp, stack0
	li a0, 4096

	csrr a1, mhartid
	addi a1, a1, 1
	mul a0, a0, a1
	add sp, sp, a0

	call start

spin:
	j spin
