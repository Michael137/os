#ifndef VICTIM_H_IN
#define VICTIM_H_IN

#include "cache.h"

// Fully set-associative cache between
// L1 and L2 DCache
class VictimCache : public cache {

public:
	// Fully set-associative => associativity == number of cache lines
	VictimCache( int blockSize, int totalCacheSize, int associativity, cache *nextLevel) :
		cache( blockSize, totalCacheSize, associativity, nextLevel, true)
	{}

	bool isVictim() { return true; }
};

#endif
