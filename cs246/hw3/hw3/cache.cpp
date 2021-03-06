//
// Generic Cache - Implementation File
//

#include <assert.h>
#include <cmath>

#include "cache.h"

cache::cache( int blockSize, int totalCacheSize, int associativity, cache* nextLevel, bool writebackDirty, std::string type,cache* lowerLevel) :
    // Set Cache properties
    blockSz(blockSize),
    totalCacheSz(totalCacheSize),
    assoc(associativity),
    // Calculate Cache bit sizes and masks
    blockOffsetSize(log2(blockSize)), 				// in bits
    setSize(log2(totalCacheSize / (blockSize * associativity))), // in bits
    tagSize(ADDRESS_SIZE - blockOffsetSize - setSize),
    tagMask( (1 << tagSize) - 1),
    setMask( (1 << setSize) - 1),
    maxSetValue((int) 1 << setSize),
    // Next level properties
    nextLevel(nextLevel),
    writebackDirty(writebackDirty),
    type(type),
    lower(lowerLevel)	// child cache
{
    // Allocate memory for the cache array
    cacheMem = new cacheEntry[totalCacheSize/blockSize];

    clearCache();

    // Clear the statistics
    totalMisses = 0;
    hits = 0;
    requests = 0;
    entriesKickedOut = 0;
}

void cache::clearCache()
{
    // Loop through entire cache array
    for( int i = 0; i < (maxSetValue) * assoc; i++ ) {
        cacheMem[ i ].LRU_status = (i % assoc);
        cacheMem[ i ].Tag = 0;
        cacheMem[ i ].Valid = false;
    }
}

unsigned int cache::getTag( unsigned int address )
{
    unsigned int ret = (address >> (blockOffsetSize + setSize)) & tagMask;
    return ret;
}

unsigned int cache::getSet( unsigned int address )
{
    // Bit Mask to get setBits
    unsigned int ret = (address >> (blockOffsetSize)) & setMask;
    return ret;
}

int cache::isHit( unsigned int tagBits, unsigned int setIndex)
{
    ///cout << "isHit.b" << endl;
    int result = -1;

    // Loop Through By Associativity
    for( int i = 0; i < assoc; i++ )
    {
        // Check if the cache location contains the requested data
        if( cacheMem[ (i + setIndex * assoc) ].Valid == true &&
                cacheMem[ (i + setIndex * assoc) ].Tag == tagBits )
        {
            return i;
            break;
        }
    }

    return result;
}

//
// Update the LRU for the system
// Input:
//  setBits - The set field of the current address
//  MRU_index - The index into the cache's array of the Most Receintly
//     Used Entry (which should be i * setBits for some int i).
// Results:
//  The entry and MRU_index will be 0 to show that it is the MRU.
//  All other entries will be updated to reflect the new MRU.
//
void cache::updateLRU( int setBits, int MRU_index )
{
    int upperBounds = assoc - 1;

    // Update all of the other places necesary to accomidate the change
    for( int i = 0; i < assoc; i++ )
    {
        if( cacheMem[ i + setBits*assoc ].LRU_status >= 0 &&
                cacheMem[ i + setBits*assoc ].LRU_status < upperBounds )
        {
            cacheMem[ i + setBits*assoc ].LRU_status++;
        }
    }

    // Set the new MRU location to show that it is the MRU
    cacheMem[ MRU_index + setBits*assoc ].LRU_status = 0;
}

//
// Input:
//   setBits - The set field of the address
// Output:
//   (int) - The index into the cache of the Least Recently Used
//     value for the given setBits field.
//    -1 If there is an error
//
int cache::getLRU( int setBits )
{
    for( int i = 0; i < assoc; i++ )
    {
        if( cacheMem[ i + setBits*assoc ].LRU_status == (assoc - 1) )
            return i;
    }
    return -1;
}

//
// Input:
//   setBits - The set field of the address
// Output:
//   (int) - The index into the cache of the Most Recently Used
//     value for the given setBits field.
//    -1 If there is an error
//
int cache::getMRU( int setBits )
{
    for( int i = 0; i < assoc; i++ )
    {
        if( cacheMem[ i + setBits*assoc ].LRU_status == 0 )
            return i;
    }
    return -1;
}
//
// Mark that the cache Missed
//
void cache::addTotalMiss()
{
    totalMisses++;
}

//
// Mark that the cache Hit
//
void cache::addHit()
{
    hits++;
}

//
// Mark that a memory request was made
//
void cache::addRequest()
{
    requests++;
}

//
// Mark that an entry was kicked out
//
void cache::addEntryRemoved()
{
    entriesKickedOut++;
}

//
// Get the total Miss Counter
//
UINT64 cache::getTotalMiss()
{
    return totalMisses;
}

//
// Get the Hit Counter
//
UINT64 cache::getHit()
{
    return hits;
}

//
// Get the requests Counter
//
UINT64 cache::getRequest()
{
    return requests;
}

//
// Get the removed entry counter
//
UINT64 cache::getEntryRemoved()
{
    return entriesKickedOut;
}

//
// Get the size of the size of the cache
//
int cache::getCacheSize()
{
    return totalCacheSz;
}

//
// Get the associativity of the cache
//
int cache::getCacheAssoc()
{
    return assoc;
}

//
// Get the block size of the cache
//
int cache::getCacheBlockSize()
{
    return blockSz;
}

//
// Access the cache. Checks for hit/miss and updates appropriate stats.
// On a miss, brings the item in from the next level. If necessary,
// writes the evicted item back to the next level.
// Doesn't distinguish between reads and writes.
//
void cache::addressRequest( unsigned long address ) {
    // Compute Set / Tag
    unsigned long tagField = getTag( address );
    unsigned long setField = getSet( address );

    // Hit or Miss ?
    int index = isHit( tagField, setField );

    // Count that access
    addRequest();

    // Miss
    if( index == -1 ) {
        // Get the LRU index
        int indexLRU = getLRU( setField );
        if( cacheMem[ indexLRU + setField*assoc].Valid == true ) {
            addEntryRemoved();
        }

        assert(nextLevel != nullptr);
	if(nextLevel->isVictim()) {
	   // std::cout << "L1 MISS " << address << std::endl;
	   unsigned long vTagField = nextLevel->getTag(address);
	   unsigned long vSetField = nextLevel->getSet(address);
	   int vHitIndex = nextLevel->isHit(vTagField, vSetField);
	   int vAssoc = nextLevel->assoc;

	   if(vHitIndex != -1) {
			addHit();
			// struct cacheEntry vHitEntry = nextLevel->cacheMem[vHitIndex + vSetField*vAssoc];
			struct cacheEntry LRUEntry = cacheMem[indexLRU + setField*assoc];

			nextLevel->cacheMem[vHitIndex + vSetField*vAssoc].Tag = LRUEntry.Tag;
			nextLevel->cacheMem[vHitIndex + vSetField*vAssoc].Valid = true;
			nextLevel->updateLRU( vSetField, vHitIndex );

			cacheMem[ indexLRU + setField*assoc].Tag = tagField; //vHitEntry.Tag;
			cacheMem[ indexLRU + setField*assoc].Valid = true;
			updateLRU( setField, indexLRU );
			return;
	   }
	}

	// Count that miss
	addTotalMiss();

	// Write the evicted entry to the next level
	if( writebackDirty &&
	    cacheMem[ indexLRU + setField*assoc].Valid == true) {
	    int tag = cacheMem[indexLRU + setField*assoc].Tag;
	    tag = tag << (getSetSize() + getBlockOffsetSize());
	    int Set = setField;
	    Set = Set << (getBlockOffsetSize());
	    unsigned long lru_addr = tag + Set;
//	    if(nextLevel->isVictim())
//	    	std::cout << "EVICTING TO VICTIM: " << lru_addr << std::endl;
	    nextLevel->addressRequest(lru_addr);
	}

	// Load the requested address from next level
	nextLevel->addressRequest(address);

	// Update LRU / Tag / Valid
	cacheMem[ indexLRU + setField*assoc].Tag = tagField; // override LRU with tag of requested address (essentially replacing cache line)
	cacheMem[ indexLRU + setField*assoc].Valid = true;
	updateLRU( setField, indexLRU ); // make LRU the MRU
    } else {
	if(isVictim())
	{
//		std::cout << "VICTIM HIT (" << address << ") FROM: " << lower->getType() << std::endl;
	}
        // Count that hit
        addHit();

        // Update LRU / Tag / Valid
        updateLRU( setField, index );
    }
}
