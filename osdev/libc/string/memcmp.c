#include <string.h>

int memcmp(const void* p1, const void* p2, size_t len)
{
	// Can't deref void*
	const unsigned char* it1 = p1;
	const unsigned char* it2 = p2;
	for(size_t i = 0; i < len; ++i)
	{
		if(it1[i] < it2[i])
			return -1;
		if(it1[i] > it2[i])
			return 1;
	}

	return 0;
}
