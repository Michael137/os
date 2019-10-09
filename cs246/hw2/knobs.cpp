#include <unistd.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "pin.H"

#include <bitset>
#include <functional>
#include <memory>

using std::cerr;
using std::string;
using std::endl;

/* ===================================================================== */
/* Commandline Switches */
/* ===================================================================== */

KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE,         "pintool",
                            "outfile", "tool.out", "Output file for the pintool");

KNOB<BOOL>   KnobPid(KNOB_MODE_WRITEONCE,                "pintool",
                            "pid", "0", "Append pid to output");

KNOB<UINT64> KnobBranchLimit(KNOB_MODE_WRITEONCE,        "pintool",
                            "branch_limit", "0", "Limit of branches analyzed");

// For sweeping 1-bit, 2-bit and adaptive predictors
KNOB<UINT64> KnobHRLength(KNOB_MODE_WRITEONCE,        "pintool",
                            "hr_len", "0", "Number of branch outcomes recorded in history register");
KNOB<UINT64> KnobHHRTEntries(KNOB_MODE_WRITEONCE,        "pintool",
                            "hhrt_sz", "0", "Size of HHRT table");
KNOB<UINT64> KnobPTEntries(KNOB_MODE_WRITEONCE,        "pintool",
                            "pt_sz", "0", "Size of PT table");
KNOB<UINT64> KnobBPredSize(KNOB_MODE_WRITEONCE,        "pintool",
                            "bpred_size", "0", "Size of 1bit/2bit prediction buffer size");
KNOB<UINT64> KnobPredictorType(KNOB_MODE_WRITEONCE,        "pintool",
                            "predictor", "0", "Choose 1-bit, 2-bit or 2-level adaptive branch predictor");

/* ===================================================================== */
/* Global Variables */
/* ===================================================================== */
UINT64 CountSeen = 0;
UINT64 CountTaken = 0;
UINT64 CountCorrect = 0;
UINT64 CountReplaced = 0;

UINT64 g_mask = 0;		// Used for 1-bit/2-bit BTB indexing
UINT64 g_predictor_type = 0;
std::ostream * out = &cerr;

/* ===================================================================== */
/* Automaton Last-Time Branch predictor                                  */
/* ===================================================================== */
struct entry_one_bit
{
    bool valid;
    bool prediction;
    UINT64 tag;
    UINT64 replace_count;
};
static std::vector<entry_one_bit> BTB_one_bit{};

/* initialize the 1-bit BTB */
VOID BTB_1bit_init()
{
    UINT64 buf_sz = KnobBPredSize.Value();
    BTB_one_bit.resize(buf_sz);
    g_mask = (buf_sz - 1);

    UINT64 i;

    for(i = 0; i < buf_sz; i++)
    {
        BTB_one_bit[i].valid = false;
        BTB_one_bit[i].tag = 0;
        BTB_one_bit[i].replace_count = 0;
    }
}

/* see if the given address is in the BTB */
bool BTB_1bit_lookup(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(BTB_one_bit[index].valid)
        if(BTB_one_bit[index].tag == ins_ptr)
            return true;

    return false;
}

/* return the prediction for the given address */
bool BTB_1bit_prediction(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    return BTB_one_bit[index].prediction;
}

/* update the BTB entry with the last result */
VOID BTB_1bit_update(ADDRINT ins_ptr, bool taken)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    BTB_one_bit[index].prediction = taken;
}

/* insert a new branch in the table */
VOID BTB_1bit_insert(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(BTB_one_bit[index].valid)
    {
        BTB_one_bit[index].replace_count++;
        CountReplaced++;
    }

    BTB_one_bit[index].valid = true;
    BTB_one_bit[index].prediction = true;
    BTB_one_bit[index].tag = ins_ptr;
}

/* ===================================================================== */
/* 2-bit Branch predictor (based on A2 automaton)			 */
/* ===================================================================== */
struct entry_two_bit
{
	bool valid;		// Inserted in history table
	int bhist;		// 2-bit prediction history
	UINT64 tag;		// Index to find via hash (i.e. branch address)
	UINT64 replace_count;	// If previous BTB entry was updated
};
static std::vector<entry_two_bit> BTB_two_bit{};

/* initialize the 2-bit BTB */
VOID BTB_2bit_init()
{
    UINT64 buf_sz = KnobBPredSize.Value();
    BTB_two_bit.resize(buf_sz);
    UINT64 i;

    g_mask = buf_sz - 1;

    for(i = 0; i < buf_sz; i++)
    {
        BTB_two_bit[i].valid = false;
        BTB_two_bit[i].bhist = 0;
        BTB_two_bit[i].tag = 0;
        BTB_two_bit[i].replace_count = 0;
    }
}

/* see if the given address is in the BTB */
bool BTB_2bit_lookup(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(BTB_two_bit[index].valid)
        if(BTB_two_bit[index].tag == ins_ptr)
            return true;

    return false;
}

/* return the prediction for the given address */
bool BTB_2bit_prediction(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    return BTB_two_bit[index].bhist >= 2;
}

/* update the BTB entry with the last result */
VOID BTB_2bit_update(ADDRINT ins_ptr, bool taken)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(taken && BTB_two_bit[index].bhist < 3)
    	BTB_two_bit[index].bhist++;
    else if(!taken && BTB_two_bit[index].bhist > 0)
    	BTB_two_bit[index].bhist--;
}

/* insert a new branch in the table */
VOID BTB_2bit_insert(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(BTB_two_bit[index].valid)
    {
        BTB_two_bit[index].replace_count++;
        CountReplaced++;
    }

    BTB_two_bit[index].valid = true;
    BTB_two_bit[index].bhist = 1;
    BTB_two_bit[index].tag = ins_ptr;
}

/* =====================================================================
 * 2-level adaptive scheme: HHRT/Pattern table + A2 automoton
 * ===================================================================== */

// LastK: indicates the length of the branch history we store
// 	  in the history table
template<int LastK> using Bits_t = std::bitset<LastK>;
template<int LastK> using Bucket_t = Bits_t<LastK>; // Our history register only store a set of bits
template<int LastK> using Buckets_t = std::vector<Bucket_t<LastK>>;

template<int LastK>
class BitTable
{
protected:
	size_t num_entries;
	Buckets_t<LastK> buckets;	// HR is an integer; collisions are handled by overwriting values
public:
	explicit BitTable(size_t tbl_size) : num_entries(tbl_size), buckets(Buckets_t<LastK>{ tbl_size }) {}

	void init(size_t tbl_size)
	{
		buckets.resize(tbl_size);
	}

	Bucket_t<LastK> history(size_t idx) { return buckets[idx]; }

	size_t hash_addr(size_t addr) { return std::hash<size_t>{}(addr); }
};

// Hash History Register Table
// LastK indicates the length of each register (in bits)
template<int LastK = 12>
class HHRT : public BitTable<LastK>
{
public:
	explicit HHRT(size_t num_entries) : BitTable<LastK>(num_entries) {}
	HHRT() : BitTable<LastK>(0) {}

	// Retreive hash register given branch address
	Bucket_t<LastK>& get(size_t addr, bool taken)
	{
		size_t hsh = this->hash_addr(addr);
		size_t idx = hsh % this->buckets.size();
		Bucket_t<LastK>& reg = this->buckets[idx];

		return reg;
	}
};

// Pattern History Table
// Each entry is a 2-bit saturating counter in our
// implementation. Alternatively LastK can be used
// to increase the width of entries. The A2 automaton
// is used to driven branch prediction
template<int LastK = 2 /*, typename Automaton */>
struct PT: public BitTable<LastK>
{
public:
	explicit PT(size_t num_entries) : BitTable<LastK>(num_entries) {}
	PT() : BitTable<LastK>(0) {}

	// Returns updated PT entry
	// Given an HHRT will retreive the corresponding PT entry and update
	// the saturating counter based on the outcome of the branch (*taken*)
	template<typename BType> void update(BType const& reg, bool taken)
	{
		// Index into PT
		Bucket_t<LastK>& pattern_hist = get(reg);

		// Update counter
		auto bit_val = pattern_hist.to_ulong();
		pattern_hist = taken ?
			((bit_val < 3) ? bit_val + 1ULL : bit_val) :
			((bit_val > 0) ? bit_val - 1ULL : bit_val);
	}

	template<typename BType> Bucket_t<LastK>& get(BType const& reg)
	{
		// Index using content of HR reg
		size_t idx = reg.to_ulong() % this->buckets.size();
		Bucket_t<LastK>& pattern_hist = this->buckets[idx];

		return pattern_hist;
	}

	// A2 prediction
	bool predict(Bucket_t<LastK> const& reg)
	{
		return reg.to_ulong() >= 2;
	}
};

/* =================================
 * Create HHRT and PT
 * HHRT's entries are 12-bit wide
 * PT's entries are 2-bit counters
 * ================================= */
static PT<2> pt_g;	// 2-bit saturating counter
static HHRT<12> hhrt_g; // history registers of 12 past outcomes

VOID AdaptiveInit()
{
	// For sweeping PT and HHRT table sizes
	pt_g.init(KnobHHRTEntries.Value());
	hhrt_g.init(KnobPTEntries.Value());
}

/* ===================================================================== */
static INT32 Usage()
{
    cerr << "This pin tool collects a profile of jump/branch/call instructions for an application\n";

    cerr << KNOB_BASE::StringKnobSummary();

    cerr << endl;
    return -1;
}

/* ===================================================================== */
VOID PrintResults(bool limit_reached)
{
    string output_file = KnobOutputFile.Value();
    if(KnobPid.Value()) output_file += "." + getpid();

    out = new std::ofstream(output_file.c_str(), std::ios_base::app);

    if(limit_reached)
        *out << "Reason: limit reached\n";
    else
        *out << "Reason: fini\n";
    *out << "Count Seen: " << CountSeen << endl;
    *out << "Count Taken: " << CountTaken << endl;
    *out << "Count Correct: " << CountCorrect << endl;
    *out << "Count Replaced: " << CountReplaced << endl;
    *out << "Percentage: " << static_cast<float>(CountCorrect) / static_cast<float>(CountSeen) << endl;
}

VOID predict_1bit(ADDRINT ins_ptr, INT32 taken)
{
    if(BTB_1bit_lookup(ins_ptr))
    {
        if(BTB_1bit_prediction(ins_ptr) == taken)
                CountCorrect++;
        BTB_1bit_update(ins_ptr, taken);
    }
    else
    {
        if(!taken)
                CountCorrect++;
        else
            BTB_1bit_insert(ins_ptr);
    }
}

VOID predict_2bit(ADDRINT ins_ptr, INT32 taken)
{
    if(BTB_2bit_lookup(ins_ptr))
    {
        if(BTB_2bit_prediction(ins_ptr) == taken)
                CountCorrect++;
        BTB_2bit_update(ins_ptr, taken);
    }
    else
    {
        if(!taken)
                CountCorrect++;
        else
            BTB_2bit_insert(ins_ptr);
    }
}

VOID predict_adaptive(ADDRINT ins_ptr, INT32 taken)
{
	// Given history register...
	auto& reg = hhrt_g.get(ins_ptr, taken);

	// get the pattern...
	auto& pat = pt_g.get(reg);

	// and predict the next branch...
	if(pt_g.predict(pat) == taken)
	        CountCorrect++;

	// then update the pattern table with the actual outcome...
	pt_g.update(reg, taken);

	// and finally update the history register
	// (shift left and insert the new outcome)
	reg <<= 1;
	reg[0] = taken; // Most recent outcome at LSB
}

/* ===================================================================== */
VOID PredictBranch(ADDRINT ins_ptr, INT32 taken)
{
    CountSeen++;
    if (taken)
        CountTaken++;

    switch(g_predictor_type)
    {
	case 0:
		predict_1bit(ins_ptr, taken);
		break;
	case 1:
		predict_2bit(ins_ptr, taken);
		break;
	case 2:
		predict_adaptive(ins_ptr, taken);
		break;
    }

    if(CountSeen == KnobBranchLimit.Value())
    {
        PrintResults(true);
        PIN_ExitProcess(EXIT_SUCCESS);
    }
}


/* ===================================================================== */
// Do not need to change instrumentation code here. Only need to modify the analysis code.
VOID Instruction(INS ins, void *v)
{
// The subcases of direct branch and indirect branch are
// broken into "call" or "not call".  Call is for a subroutine
// These are left as subcases in case the programmer wants
// to extend the statistics to see how sub cases of branches behave
    if( INS_IsRet(ins) )
    {
        INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
            IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
    }
    else if( INS_IsSyscall(ins) )
    {
        INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
            IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
    }
    else if (INS_IsDirectBranch(ins) or INS_IsDirectCall(ins))
    {
        if( INS_IsCall(ins) ) {
            INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
                IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
        }
        else {
            INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
                IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
        }
    }
    else if( INS_IsBranch(ins) or INS_IsCall(ins) ) //"and INS_IsDirectCall/Branch(ins)" would be redundant
    {
        if( INS_IsCall(ins) ) {
            INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
                IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
    }
        else {
            INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) PredictBranch,
                IARG_INST_PTR, IARG_BRANCH_TAKEN,  IARG_END);
        }
    }

}

/* ===================================================================== */
VOID Fini(int n, void *v)
{
    PrintResults(false);
}

/* ===================================================================== */
int main(int argc, char *argv[])
{
    if( PIN_Init(argc,argv) )
    {
        return Usage();
    }

    g_predictor_type = KnobPredictorType.Value();
    switch(g_predictor_type)
    {
	case 0:
    		BTB_1bit_init();
		break;
	case 1:
    		BTB_2bit_init();
		break;
	case 2:
    		AdaptiveInit();
		break;
    }

    INS_AddInstrumentFunction(Instruction, 0);
    PIN_AddFiniFunction(Fini, 0);

    PIN_StartProgram();

    return 0;
}
