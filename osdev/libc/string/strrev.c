#include <string.h>

char* strrev(char* str)
{
	size_t len = strlen(str) - 1;
	if(len == 1)
		return str;

	char tmp;
	for(size_t i = 0; i < len / 2; ++i)
	{
		tmp = str[i];
		str[i] = str[len - i];
		str[len - i] = tmp;
	}

	return str;
}
