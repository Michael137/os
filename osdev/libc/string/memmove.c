#include <string.h>

void* memmove(void* dest, const void* src, size_t len)
{
	unsigned char* dptr = dest;
	const unsigned char* sptr = src;

	if(dptr <= sptr)
	{
		for(size_t i = 0; i < len; ++i)
			dptr[i] = sptr[i];
	} else {
		// Awkward indices and condition
		// because "i" is unsigned and
		// won't terminate if checked
		// with >= 0
		for(size_t i = len; i != 0; --i)
			dptr[i-1] = sptr[i-1];
	}

	// Return defined by C standard
	return dest;
}
