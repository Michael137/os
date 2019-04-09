#ifndef KERNEL_TTY_H_IN
#define KERNEL_TTY_H_IN

#include <stddef.h>
#include <stdint.h>

void terminal_initialize(void);
void terminal_setcolor(uint8_t color);
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y);
void terminal_putchar(char c);
void terminal_write(const char* data, size_t size);
void terminal_writestring(const char* data);
uint8_t terminal_getcolor();
uint8_t terminal_getrow();
uint8_t terminal_getcol();

// TODO: find better place for this
void terminal_welcome_message();

#endif // KERNEL_TTY_H_IN
