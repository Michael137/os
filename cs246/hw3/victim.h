//here goes your implementation of the victim cache.

#ifndef VICTIM_H_IN
#define VICTIM_H_IN

// Fully set-associative cache between
// L1 and L2 DCache
class VictimCache : public cache {

public:
	// Fully set-associative => associativity == number of cache lines
	VictimCache( int blockSize, int totalCacheSize, int associativity, cache *nextLevel) :
		cache( blockSize, totalCacheSize, associativity, nextLevel, true, "VictimCache") // TODO: check whether writebackDirty should be disabled for victim cache
	{}

	bool isVictim() { return true; }

	// TODO: override cache::addressRequest which is called from hw3.cpp in Instruction(...)->MemoryOp
	//       all mem read/write instructions encountered by pin issue a memoryop event (which is an access into dcache)
	//       all instructions issue a icache address request
};


#endif
