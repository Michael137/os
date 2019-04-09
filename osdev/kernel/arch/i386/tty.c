#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include <kernel/tty.h>

#include "vga.h" // VGA constants

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static uint16_t* terminal_buffer;
 
void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREEN,VGA_COLOR_DARK_GREY);
	terminal_buffer = VGA_MEMORY;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}
 
void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}
 
// Put character into terminal buffer at given row/column
// depending on VGA_WIDTH
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}
 
// Put character into terminal buffer via terminal_putentryat.
// Wrap cursor location to new row and 0th column if we
// enter character at last possible slot in row
void terminal_putchar(char c) 
{
	if(c != '\n')
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if ( ++terminal_column == VGA_WIDTH || c == '\n') {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT) {
			// Shift all rows up by one
			// XXX: memmove() instead?
			for(size_t i = 0; i < VGA_HEIGHT - 1; ++i)
			{
				for(size_t j = 0; j < VGA_WIDTH; ++j)
				{
					size_t idx = i * VGA_WIDTH + j;
					size_t next_idx = (i + 1) * VGA_WIDTH + j;
					terminal_buffer[idx] = terminal_buffer[next_idx];
				}
			}
			// Leave last row blank
			terminal_row = VGA_HEIGHT - 1;
			for(size_t j = 0; j < VGA_WIDTH; ++j)
				terminal_putentryat(' ', terminal_color, j, terminal_row);
		}
	}
}
 
// Repeatedly write specified portion of characters of
// null-terminated string to terminal buffer
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}
 
// Write whole null-terminated string to terminal
void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}

uint8_t terminal_getcolor()
{
	return terminal_color;
}

uint8_t terminal_getrow()
{
	return terminal_row;
}

uint8_t terminal_getcol()
{
	return terminal_column;
}

/*
 *
 * |-------------|
 * | ########### |
 * |   ooooooo   |
 * | ########### |
 * |-------------|**
 *              *****
 *                ***
 */
void terminal_welcome_message()
{
	terminal_writestring("Welcome to OccamOs\n\n");
	const size_t logo_width = 10;
	// const size_t logo_height = 5;
	const uint8_t old_color = terminal_color;
	const uint8_t silver = vga_entry_color(VGA_COLOR_LIGHT_GREY,VGA_COLOR_LIGHT_GREY);
	const uint8_t white = vga_entry_color(VGA_COLOR_WHITE,VGA_COLOR_WHITE);
	const uint8_t black = vga_entry_color(VGA_COLOR_DARK_GREY,VGA_COLOR_DARK_GREY);
	const uint8_t red = vga_entry_color(VGA_COLOR_RED,VGA_COLOR_RED);
	terminal_setcolor(silver);
	terminal_putchar('|');
	for(size_t i = 0; i < logo_width - 2; ++i)
		terminal_putchar('-');
	terminal_putchar('|');
	terminal_putchar('\n');

	terminal_writestring("| ");
	terminal_setcolor(white);
	for(size_t i = 0; i < logo_width - 4; ++i)
		terminal_putchar('#');
	terminal_setcolor(silver);
	terminal_writestring(" |");
	terminal_putchar('\n');

	terminal_writestring("|  ");
	terminal_setcolor(black);
	for(size_t i = 0; i < logo_width - 6; ++i)
		terminal_putchar('o');
	terminal_setcolor(silver);
	terminal_writestring("  |");
	terminal_putchar('\n');

	terminal_writestring("| ");
	terminal_setcolor(white);
	for(size_t i = 0; i < logo_width - 4; ++i)
		terminal_putchar('#');
	terminal_setcolor(silver);
	terminal_writestring(" |");
	terminal_putchar('\n');

	terminal_setcolor(silver);
	terminal_putchar('|');
	for(size_t i = 0; i < logo_width - 2; ++i)
		terminal_putchar(' ');
	terminal_setcolor(red);
	terminal_writestring("***");
	terminal_putchar('\n');

	terminal_setcolor(old_color);
	for(size_t i = 0; i < logo_width - 2; ++i)
		terminal_putchar(' ');
	terminal_setcolor(red);
	terminal_writestring("*****");
	terminal_putchar('\n');

	terminal_color = old_color;
}
