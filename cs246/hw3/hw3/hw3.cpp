#include "pin.H"
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

#include "memory.h"
#include "L1InstCache.h"
#include "L1DataCache.h"
#include "L2Cache.h"
#include "victim.h"

using namespace std;
/*
This code implements a simple cache simulator. In this implementation, we
assume there is L1 Instruction Cache, L1 Data Cache, and L2 Cache.

We have a base class declared in cache.h file and three derived classes:
L1InstCache, L1DataCache, and L2Cache.

We have a simple memory class to track the number of memory requests.

This is a simplified cache model since we do not differentiate read and write
accesses, which is not true for real cache system.

We only track the number of hits and misses in both L1 and L2 caches.

In both L1 and L2 caches, we use a simple LRU algorithm as cache replacement policy.

*/

/* ===================================================================== */
/* Commandline Switches */
/* ===================================================================== */
KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE,    "pintool",
        "outfile", "cache.out", "Cache results file name");

KNOB<string> KnobConfigFile(KNOB_MODE_WRITEONCE,    "pintool",
        "config", "config-base", "Configuration file name");

KNOB<UINT64> KnobInstructionCount(KNOB_MODE_WRITEONCE, "pintool",
        "max_inst","1000000000", "Number of instructions to profile");

KNOB<int> KnobWithVictim(KNOB_MODE_WRITEONCE, "pintool",
        "victim","1", "Run with or without victim cache");

KNOB<int> KnobVerbose(KNOB_MODE_WRITEONCE, "pintool",
        "verbose","0", "Print cache information in results or not");

// Globals for the various caches
/* ===================================================================== */
l1icache* icache;
l1dcache* dcache;
l2cache* llcache;
VictimCache* victim;
memory* mem;

// Keep track if instruction counts so we know when to end simmulation
UINT64 icount;

void PrintResults(void);

/* ===================================================================== */
INT32 Usage()
{
    cerr << "This tool represents a cache simulator.\n"
        "\n";

    cerr << KNOB_BASE::StringKnobSummary();

    cerr << endl;

    return -1;
}


/* ===================================================================== */
void CreateCaches(void)
{
    // Check if config file exits
    ifstream config;
    config.open( KnobConfigFile.Value().c_str());
    if(!config.is_open()) {
        cerr << "Cannot open input file : " << KnobConfigFile.Value() << "\n";
        Usage();
        PIN_ExitProcess(EXIT_FAILURE);
    }

    // Create the one and only memory
    mem = new memory(llcache);

    // Parse config file and create the three caches
    int i = 0;
    while (!config.eof()){
        string line;
        getline(config, line);
        istringstream parser(line);
        int bsize, csize, assoc, vsize;
        char comma = ',';
        switch(i){
            case 0:
                parser >> bsize >> comma >> csize >> comma >> assoc;
                llcache = new l2cache(bsize, csize, assoc, mem,victim);
                break;
            case 1:
                parser >> bsize >> comma >> csize >> comma >> assoc;
                icache = new l1icache(bsize, csize, assoc, llcache,nullptr);
                break;
            case 2:
                parser >> bsize >> comma >> csize >> comma >> assoc >> comma >> vsize;
		if(KnobWithVictim.Value() != 0) {
			victim = new VictimCache(bsize, bsize * vsize, vsize, llcache, dcache);
			dcache = new l1dcache(bsize, csize, assoc, victim,nullptr);
			victim->setLowerLevel(dcache);
		} else {
			dcache = new l1dcache(bsize, csize, assoc, llcache, nullptr);
		}
                break;
            default:
                break;
        }
        i++;
    }
}

/* ===================================================================== */
void CheckInstructionLimits(void)
{
    if (KnobInstructionCount.Value() > 0 &&
        icount > KnobInstructionCount.Value()) {
        PrintResults();
        PIN_ExitProcess(EXIT_SUCCESS);
    }
}

/* ===================================================================== */
void MemoryOp(ADDRINT address)
{
    //std::cout << "AR Started" << std::endl;
    dcache->addressRequest( address );
    //std::cout << "AR Finished" << std::endl;
}

/* ===================================================================== */
void AllInstructions(ADDRINT ins_ptr)
{
    icount++;
    icache->addressRequest( ins_ptr );

    CheckInstructionLimits();
}

/* ===================================================================== */
void PrintResults(void)
{
    ofstream out(KnobOutputFile.Value().c_str());

    //std::cout << "FINISHED PIN" << std::endl;

    out.setf(ios::fixed, ios::floatfield);
    out.precision(2);

    if(KnobVerbose.Value() != 0) {
	    out << "---------------------------------------";
	    out << endl << "\t\tSimulation Results" << endl;
	    out << "---------------------------------------";

	    out << endl
		<< "Memory system->" << endl
		<< "\t\tDcache size (bytes)         : " << dcache->getCacheSize() << endl
		<< "\t\tDcache ways                 : " << dcache->getCacheAssoc() << endl
		 << "\t\tDcache block size (bytes)   : " << dcache->getCacheBlockSize() << endl;

	    if(KnobWithVictim.Value()) {
		    out << endl
			<< "\t\tVictimCache size (bytes)         : " << victim->getCacheSize() << endl
			<< "\t\tVictimCache ways                 : " << victim->getCacheAssoc() << endl
			 << "\t\tVictimCache block size (bytes)   : " << victim->getCacheBlockSize() << endl;
	    }

	    out << endl
		<< "\t\tIcache size (bytes)         : " << icache->getCacheSize() << endl
		<< "\t\tIcache ways                 : " << icache->getCacheAssoc() << endl
		<< "\t\tIcache block size (bytes)   : " << icache->getCacheBlockSize() << endl;

	    out << endl
		<< "\t\tL2-cache size (bytes)       : " << llcache->getCacheSize() << endl
		<< "\t\tL2-cache ways               : " << llcache->getCacheAssoc() << endl
		<< "\t\tL2-cache block size (bytes) : " << llcache->getCacheBlockSize() << endl;

	    out << "Simulated events->" << endl;

	    out << "\t\t I-Cache Miss: " << icache->getTotalMiss() << " out of " << icache->getRequest() << endl;

	    out << "\t\t D-Cache Miss: " << dcache->getTotalMiss() << " out of " << dcache->getRequest() << endl;
	    out << "\t\t D-Cache Perc.: " << 100 * static_cast<float>(dcache->getTotalMiss())/static_cast<float>(dcache->getRequest()) << "%" << endl;

	    out << "\t\t L2-Cache Miss: " << llcache->getTotalMiss() << " out of " << llcache->getRequest() << endl;

	    out << endl;

	    out << "\t\t Requests resulted in " << icache->getRequest() + dcache->getRequest() << " L1 requests, "
		<< llcache->getRequest() << " L2 requests, "
		<< (*mem).getRequest() << " mem requests " << endl;

	    out << endl;

	    out << endl;
	    out << "------------------------------------------------";
	    out << endl;
    } else {
            out.precision(6);
	    if(KnobWithVictim.Value()) {
		    out << victim->getCacheAssoc() << "," << dcache->getTotalMiss() << "," << dcache->getRequest() << "," << static_cast<float>(dcache->getTotalMiss())/static_cast<float>(dcache->getRequest()) << endl;
	    } else {
		    out << dcache->getCacheAssoc() << "," << dcache->getTotalMiss() << "," << dcache->getRequest() << "," << static_cast<float>(dcache->getTotalMiss())/static_cast<float>(dcache->getRequest()) << endl;
	    }
    }
}

/// Add instruction instrumentation calls
/* ===================================================================== */
void Instruction(INS ins, VOID *v)
{
    // All instructions access the icache
    INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) AllInstructions,
            IARG_INST_PTR, IARG_END);

    //std::cout << "PIN CHECK 1" << std::endl;
    // Reads go to dcache
    if (INS_IsMemoryRead(ins)) {
        INS_InsertPredicatedCall(
                ins, IPOINT_BEFORE, (AFUNPTR) MemoryOp,
                IARG_MEMORYREAD_EA,
                IARG_END);

    }

    //std::cout << "PIN CHECK 2" << std::endl;
    // Writes go to dcache
    // XXX: note this is not an else branch. It's pretty typical for an x86
    // instruction to be both a read and a write.
    if ( INS_IsMemoryWrite(ins) ) {
        INS_InsertPredicatedCall(
                ins, IPOINT_BEFORE,  (AFUNPTR) MemoryOp,
                IARG_MEMORYWRITE_EA,
                IARG_END);
    }
    // std::cout << "PIN DONE" << std::endl;
}

/* ===================================================================== */
void Fini(int n, VOID *v)
{
    PrintResults();
}

/* ===================================================================== */
int main(int argc, char *argv[])
{
    if( PIN_Init(argc,argv) ){
        return Usage();
    }

    CreateCaches();

    INS_AddInstrumentFunction(Instruction, 0);

    PIN_AddFiniFunction(Fini, 0);

    PIN_StartProgram();

    return 0;
}
