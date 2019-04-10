.section .init
	/* gcc puts contents of crtend.o's .init section here */
	popl %ebp
	ret

.section .fini
	/* gcc puts contents of crtend.o's .fini section here */
	popl %ebp
	ret
