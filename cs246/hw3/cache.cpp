//
// Generic Cache - Implementation File
//

#include <assert.h>
#include <cmath>

#include "cache.h"

cache::cache( int blockSize, int totalCacheSize, int associativity, cache* nextLevel, bool writebackDirty, std::string type) :
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
    type(type)
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
    std::cout << type << std::endl;
    // Compute Set / Tag
    unsigned long tagField = getTag( address );
    unsigned long setField = getSet( address );

    // Hit or Miss ?
    int index = isHit( tagField, setField );
    // std::cout << type << " " << (index != -1) << std::endl;

    // Count that access
    addRequest();

    // Miss
    if( index == -1 ) {
    	std::cout << "CACHE MISS" << std::endl;
        // Get the LRU index
        int indexLRU = getLRU( setField );
        if( cacheMem[ indexLRU + setField*assoc].Valid == true ) {
            addEntryRemoved();
        }

        assert(nextLevel != nullptr);
	if(nextLevel->isVictim()) {
		int hitIndex = -1;
		if((hitIndex = nextLevel->isHit(tagField, setField)) != -1) {
			// TODO: increment hit as well?
			std::cout << "VICTIM HIT " << hitIndex << std::endl;
			addHit();
			struct cacheEntry tmp;
			tmp.Tag = nextLevel->cacheMem[hitIndex + setField*assoc].Tag;
			tmp.LRU_status = nextLevel->cacheMem[hitIndex + setField*assoc].LRU_status;

			// TODO: what if associativity of victim and L1 is not the same; setField might need to change
			nextLevel->cacheMem[ hitIndex + setField*assoc].Tag = cacheMem[indexLRU + setField*assoc].Tag; 
			nextLevel->cacheMem[ hitIndex + setField*assoc].Valid = true;
			nextLevel->updateLRU( setField, hitIndex );

			cacheMem[ indexLRU + setField*assoc].Tag = tmp.Tag; // TODO: what if associativity of victim and L1 is not the same; setField might need to change
			cacheMem[ indexLRU + setField*assoc].Valid = true;
			// cacheMem[ indexLRU + setField*assoc].LRU_status = tmp.LRU_status;
			updateLRU( setField, indexLRU );
		} else {
			std::cout << "VICTIM MISS" << std::endl;

			nextLevel->cacheMem[ indexLRU + setField*assoc].Tag = cacheMem[indexLRU + setField*assoc].Tag; // TODO: what if associativity of victim and L1 is not the same; setField might need to change
			nextLevel->cacheMem[ indexLRU + setField*assoc].Valid = true;
			nextLevel->updateLRU( setField, indexLRU );

			nextLevel->nextLevel->addressRequest(address);
			cacheMem[ indexLRU + setField*assoc].Tag = tagField;
			cacheMem[ indexLRU + setField*assoc].Valid = true;
			updateLRU( setField, indexLRU );
			std::cout << "UPDATED LRU FROM VICTIM CACHE" << std::endl;
		}
	} else {
		std::cout << "NOT VICTIM" << std::endl;
        	// Count that miss
        	addTotalMiss();

		// Write the evicted entry to the next level
		if( writebackDirty &&
		    cacheMem[ indexLRU + setField*assoc].Valid == true) {
		    int tag = cacheMem[indexLRU + setField*assoc].Tag;
		    //std::cout << tag << " " << (getSetSize() + getBlockOffsetSize()) << indexLRU << std::endl;
		    tag = tag << (getSetSize() + getBlockOffsetSize());
		    int Set = setField;
		    Set = Set << (getBlockOffsetSize());
		    //std::cout << setField << " " << Set << std::endl;
		    int lru_addr = tag + Set;
		    //std::cout << "New addr: " << lru_addr << std::endl;
		    nextLevel->addressRequest(lru_addr);
		}

		std::cout << "Miss to next level" << std::endl;

		// Load the requested address from next level
		nextLevel->addressRequest(address);

		std::cout << "Returned from next level" << std::endl;

		// Update LRU / Tag / Valid
		cacheMem[ indexLRU + setField*assoc].Tag = tagField;
		cacheMem[ indexLRU + setField*assoc].Valid = true;
		updateLRU( setField, indexLRU );
		std::cout << "Updated LRU" << std::endl;
	}
    }
    else {
	    std::cout << "CACHE HIT" << std::endl;
        // Count that hit
        addHit();

        // Update LRU / Tag / Valid
        updateLRU( setField, index );
    }
}
