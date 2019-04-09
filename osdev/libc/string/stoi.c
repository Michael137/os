#include <stdio.h>

// User has to make sure that str_out
// is large enough to store integers.
// Returns base-10 representation of
// integer.
char* stoi(int i, char* str_out) {
	int ctr = 0;
	while(i > 9)
	{
		str_out[ctr] = (i % 10) + '0';
		i /= 10;
		ctr++;
	}
	str_out[ctr] = i + '0';
	str_out[ctr+1] = '\0';

	return str_out;
}
