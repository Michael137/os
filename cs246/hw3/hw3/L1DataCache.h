//
// L1 Data Cache
//

#ifndef __L_1_D_CACHE__
#define __L_1_D_CACHE__

#include "cache.h"

class l1dcache : public cache {
public:
    l1dcache( int blockSize, int totalCacheSize, int associativity, cache *nextLevel, cache* lowerLevel) :
        cache( blockSize, totalCacheSize, associativity, nextLevel, true, "L1Cache", lowerLevel)
    {}
};

#endif
