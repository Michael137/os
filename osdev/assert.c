#include <stdio.h>

#ifndef assert
	#ifdef NDEBUG
		#define assert(_) ((void)NULL)
	#else
		#define assert(e) \
			((void)((e) ? 0 : (__myassert(#e, __FILE__, __LINE__), 0)))
 
		#define __myassert(expression, file, line)  \
			__myassfail("Failed assertion `%s' at line %d of `%s'.",    \
							expression, line, file)
	#endif // DEBUG
#endif // assert
