#include <string.h>

void* memcpy(void* restrict dest, const void* restrict src, size_t len)
{
	unsigned char* dptr = dest;
	unsigned const char* sptr = src;
	for(size_t i = 0; i < len; ++i)
		dptr[i] = (unsigned char) sptr[i];

	// Return defined by C standard
	return dest;
}
