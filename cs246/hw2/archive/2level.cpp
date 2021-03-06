#include <unistd.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "pin.H"

#include <bitset>
#include <functional>

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
                            "branch_limit", "0", "Nimit of branches analyzed");

KNOB<UINT64> KnobHRLength(KNOB_MODE_WRITEONCE,        "pintool",
                            "hr_len", "0", "Number of branch outcomes recorded in history register");
KNOB<UINT64> KnobHHRTEntries(KNOB_MODE_WRITEONCE,        "pintool",
                            "hhrt_sz", "0", "Size of HHRT table");
KNOB<UINT64> KnobPTEntries(KNOB_MODE_WRITEONCE,        "pintool",
                            "pt_sz", "0", "Size of PT table");


/* ===================================================================== */
/* Global Variables */
/* ===================================================================== */
UINT64 CountSeen = 0;
UINT64 CountTaken = 0;
UINT64 CountCorrect = 0;
UINT64 CountReplaced = 0;

std::ostream * out = &cerr;

const int bpred_size = 1024;
UINT64 mask = (bpred_size-1);

/* ===================================================================== */
/* Automaton Last-Time Branch predictor                                  */
/* ===================================================================== */
struct entry_one_bit
{
    bool valid;
    bool prediction;
    UINT64 tag;
    UINT64 replace_count;
} BTB_one_bit[bpred_size];

/* ===================================================================== */
/* Automaton A2 Branch predictor                                         */
/* ===================================================================== */
struct entry_two_bit
{
	bool valid;		// Inserted in history table
	int bhist;		// 2-bit prediction history
	UINT64 tag;		// Index to find via hash (i.e. branch address)
	UINT64 replace_count;	// If previous BTB entry was updated
} BTB_two_bit[bpred_size];

/* =====================================================================
 * 2-level adaptive scheme: HHRT/Pattern table + A2 automoton
 * ===================================================================== */
template<int LastK> using Bits_t = std::bitset<LastK>;

// History register
template<int LastK>
struct HR
{
	bool valid;
	UINT64 tag;
	std::bitset<LastK> bits;
	int hist_len;			// Counts up to LastK
	int collisions;

	HR() : valid(false), tag(), bits(std::bitset<LastK>{}), hist_len(), collisions() {}
};

template<int LastK> using Bucket_t = HR<LastK>;
template<int LastK> using Buckets_t = std::vector<Bucket_t<LastK>>;

template<int LastK, size_t TblSize>
class BitTable
{
protected:
	Buckets_t<LastK> buckets;	// HR is an integer; collisions are handled by overwriting values
public:
	BitTable() : buckets(Buckets_t<LastK>{ TblSize }) {}

	Bucket_t<LastK> history(size_t idx) { return buckets.bits[idx]; }

	size_t hash_addr(size_t addr) { return std::hash<size_t>{}(addr); }

//	Bucket_t<LastK> update(size_t addr, bool taken) = 0;
};

template<int LastK = 12, size_t TblSize = 512>
class HHRT : public BitTable<LastK, TblSize>
{
public:
	HHRT() : BitTable<LastK, TblSize>() {}

	Bucket_t<LastK>& update(size_t addr, bool taken)
	{
		size_t hsh = this->hash_addr(addr);
		size_t idx = hsh % this->buckets.size();
		Bucket_t<LastK>& reg = this->buckets[idx];
		reg.bits <<= 1;
		reg.bits[0] = taken; // Most recent outcome at LSB
		reg.tag = addr;

		if(reg.valid)
		{
			reg.collisions++; // Not necessarily collision but acts as "replace_count"
			CountReplaced++;
		} else
			reg.valid = true;

		return reg;
	}

	bool exists(size_t addr)
	{
		size_t hsh = this->hash_addr(addr);
		size_t idx = hsh % this->buckets.size();
		return this->buckets[idx].valid;
	}
};

// The branch behaviour for the last s occurrences of the unique
// branch history of the last n branches
//
// Branch result sets HHRT register but also drives
// the automaton that will set the pattern history bit
// in this PT
template<int LastK = 2, int TblSize = 65536 /*, typename Automaton */>
struct PT: public BitTable<LastK, TblSize>
{
public:
	PT() : BitTable<LastK, TblSize>() {}

	template<typename BType> size_t hash_hr(BType hr)
	{
		//return std::hash<Bucket_t<LastK>>{}(hr);
		return std::hash<unsigned>{}(hr.bits.to_ulong()); // std::bitset hash only available in C++11
	}

	template<typename BType> Bucket_t<LastK>& update(BType reg, bool taken)
	{
		// Index
		size_t hsh = hash_hr(reg);
		size_t idx = hsh % this->buckets.size();
		Bucket_t<LastK>& pattern_hist = this->buckets[idx];

		//// Predict
//		size_t prediction = A2(pattern_hist, taken);
//		pattern_hist.hist_len = std::min(pattern_hist.hist_len + 1, LastK);
//
//		//// Update
//		pattern_hist.bits <<= 1;
//		pattern_hist.bits[0] = prediction;

		// Pattern is saturating counter of LastK length
		pattern_hist.hist_len = std::min(pattern_hist.hist_len + 1, LastK);
		auto bit_val = pattern_hist.bits.to_ulong();
		pattern_hist.bits = taken ?
			((bit_val < 3) ? bit_val + 1ULL : bit_val) :
			((bit_val > 0) ? bit_val - 1ULL : bit_val);

		return pattern_hist;
	}

	bool predict(Bucket_t<LastK> const& reg)
	{
		return reg.bits.to_ulong() >= 2;
	}

	// Use pattern history bits to predict branch
	bool A2_predict(int ctr)
	{
		return ctr >= 2;
	}

	// A2 automaton
	size_t A2(Bucket_t<LastK> pattern, bool taken)
	{
		int saturating_ctr = 0;
		//std::cout << pattern.hist_len << std::endl;
		for(int i = 0; i < pattern.hist_len; ++i)
		{
			if(pattern.bits[i]) {
				if(saturating_ctr < 3)
					saturating_ctr++; }
			else {
				if(saturating_ctr > 0)
					saturating_ctr--; }
		}

		saturating_ctr += taken ? 1 : -1;
		//std::cout << saturating_ctr << std::endl;
		return this->A2_predict(saturating_ctr);
	}
};

PT<2, 4096> pt_g{};	// 2-bit saturating counter; 4096 entries
HHRT<12, 512> hhrt_g{};	// 512 entries recording history of 12 past outcomes

/* initialize the BTB */
VOID BTB_init()
{
    int i;

    for(i = 0; i < bpred_size; i++)
    {
        BTB_two_bit[i].valid = false;
        BTB_two_bit[i].bhist = 0;
        BTB_two_bit[i].tag = 0;
        BTB_two_bit[i].replace_count = 0;
    }
}

/* see if the given address is in the BTB */
bool BTB_lookup(ADDRINT ins_ptr)
{
    UINT64 index;

    index = mask & ins_ptr;

    if(BTB_two_bit[index].valid)
        if(BTB_two_bit[index].tag == ins_ptr)
            return true;

    return false;
}

/* return the prediction for the given address */
bool BTB_prediction(ADDRINT ins_ptr)
{
    UINT64 index;

    index = mask & ins_ptr;

    return BTB_two_bit[index].bhist >= 2;
}

/* update the BTB entry with the last result */
VOID BTB_update(ADDRINT ins_ptr, bool taken)
{
    UINT64 index;

    index = mask & ins_ptr;

    if(taken)
    	BTB_two_bit[index].bhist++;
    else
    	BTB_two_bit[index].bhist--;
}

/* insert a new branch in the table */
VOID BTB_insert(ADDRINT ins_ptr)
{
    UINT64 index;

    index = mask & ins_ptr;

    if(BTB_two_bit[index].valid)
    {
        BTB_two_bit[index].replace_count++;
        CountReplaced++;
    }

    BTB_two_bit[index].valid = true;
    BTB_two_bit[index].bhist++;
    BTB_two_bit[index].tag = ins_ptr;
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

    //std::ofstream out(output_file.c_str());
    if (!output_file.empty()) { out = new std::ofstream(output_file.c_str());}

    if(limit_reached)
        *out << "Reason: limit reached\n";
    else
        *out << "Reason: fini\n";
    *out << "Count Seen: " << CountSeen << endl;
    *out << "Count Taken: " << CountTaken << endl;
    *out << "Count Correct: " << CountCorrect << endl;
    *out << "Count Replaced: " << CountReplaced << endl;
}

/* ===================================================================== */
VOID PredictBranch(ADDRINT ins_ptr, INT32 taken)
{
    CountSeen++;
    if (taken)
        CountTaken++;

//    if(BTB_lookup(ins_ptr))
//    {
//        if(BTB_prediction(ins_ptr) == taken)
//                CountCorrect++;
//        BTB_update(ins_ptr, taken);
//    }
//    else
//    {
//        if(!taken)
//                CountCorrect++;
//        else
//            BTB_insert(ins_ptr);
//    }

    auto reg = hhrt_g.update(ins_ptr, taken);
    //std::cout << reg.bits << std::endl;
    auto pattern = pt_g.update(reg, taken);
//    std::cout << pattern.bits << std::endl;
    bool p = pt_g.predict(pattern);
    if(p == taken)
	    CountCorrect++;

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

    BTB_init();

    INS_AddInstrumentFunction(Instruction, 0);
    PIN_AddFiniFunction(Fini, 0);

    PIN_StartProgram();

    return 0;
}
