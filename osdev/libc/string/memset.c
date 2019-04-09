#include <string.h>

void* memset(void* ptr, int val, size_t len)
{
	// Can't deref void*
	unsigned char* buf = ptr;
	for(size_t i = 0; i < len; ++i)
		buf[i] = (unsigned char) val;

	return buf;
}
