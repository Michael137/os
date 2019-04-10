#ifndef STRING_H_IN
#define STRING_H_IN

#include <sys/cdefs.h>
#include <stddef.h>

int memcmp(const void*, const void*, size_t);
void* memcpy(void* restrict dest, const void* restrict src, size_t);
void* memmove(void* dest, const void* src, size_t);
void* memset(void*, int, size_t);
size_t strlen(const char*);
char* itoa(int, char* str_out);
char* strrev(char*);

#endif // STRING_H_IN
