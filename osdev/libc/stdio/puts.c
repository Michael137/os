#include <stdio.h>

// Return EOF on failure
int puts(const char* str)
{
	return (printf("%s\n", str) < 0) ? EOF : 1;
}
