#include <stdio.h>

#if defined(__is_libk)
#include <kernel/tty.h>
#endif

int putchar(int c_in) {
	char c = (char) c_in;
	terminal_write(&c, sizeof(c));
	return c_in;
}
