#include <stdint.h>
#include <stdio.h>

#include <kernel/tty.h>
 
/* Check if the compiler thinks you are targeting the wrong operating system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
/* TODO: occamos only works for the 32-bit ix86 targets at the moment. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

// Kernel entry point
void kernel_main(void) 
{
	/* Initialize terminal interface */
	terminal_initialize();
 
	terminal_welcome_message("Welcome to OccamOs\n\n");
	puts("");
	puts("");
	printf("by %s%d\n", "gardei", 137);
}
