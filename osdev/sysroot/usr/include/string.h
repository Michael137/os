#ifndef STRING_H_IN
#define STRING_H_IN

#include <sys/cdefs.h>
#include <stddef.h>

// int memcmp(const void*, const void*, size_t);
// void* memcpy(void* __restrict src, const void* __restrict dest, size_t);
// void* memmove(void* dest, const void* src, size_t);
// void* memset(void*, int, size_t);
size_t strlen(const char*);
char* stoi(int, char* str_out);

#endif // STRING_H_IN
