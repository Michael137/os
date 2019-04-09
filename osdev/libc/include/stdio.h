#ifndef STDIO_H_IN
#define STDIO_H_IN

#include <sys/cdefs.h>

#define EOF (-1)

int printf(const char* restrict, ...);
int putchar(int);
int puts(const char*);

#endif // STDIO_H_IN
