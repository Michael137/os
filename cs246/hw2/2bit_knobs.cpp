#include <unistd.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "pin.H"


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

KNOB<UINT64> KnobBPredSize(KNOB_MODE_WRITEONCE,        "pintool",
                            "bpred_size", "0", "Size of 1bit/2bit prediction buffer size");

/* ===================================================================== */
/* Global Variables */
/* ===================================================================== */
UINT64 CountSeen = 0;
UINT64 CountTaken = 0;
UINT64 CountCorrect = 0;
UINT64 CountReplaced = 0;

UINT64 g_mask = 0;
std::ostream * out = &cerr;

/* ===================================================================== */
/* Automaton A2 Branch predictor                                         */
/* ===================================================================== */
struct entry_two_bit
{
	bool valid;		// Inserted in history table
	int bhist;		// 2-bit prediction history
	UINT64 tag;		// Index to find via hash (i.e. branch address)
	UINT64 replace_count;	// If previous BTB entry was updated
};
static std::vector<entry_two_bit> BTB_two_bit{};

/* initialize the BTB */
VOID BTB_init()
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
bool BTB_lookup(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(BTB_two_bit[index].valid)
        if(BTB_two_bit[index].tag == ins_ptr)
            return true;

    return false;
}

/* return the prediction for the given address */
bool BTB_prediction(ADDRINT ins_ptr)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    return BTB_two_bit[index].bhist >= 2;
}

/* update the BTB entry with the last result */
VOID BTB_update(ADDRINT ins_ptr, bool taken)
{
    UINT64 index;

    index = g_mask & ins_ptr;

    if(taken)
    	BTB_two_bit[index].bhist++;
    else
    	BTB_two_bit[index].bhist--;
}

/* insert a new branch in the table */
VOID BTB_insert(ADDRINT ins_ptr)
{
    UINT64 index;

    //index = mask & ins_ptr;
    index = (BTB_two_bit.size() - 1) & ins_ptr;

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
    if (!output_file.empty()) { out = new std::ofstream(output_file.c_str(), std::ios_base::app);}

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

    if(BTB_lookup(ins_ptr))
    {
        if(BTB_prediction(ins_ptr) == taken)
                CountCorrect++;
        BTB_update(ins_ptr, taken);
    }
    else
    {
        if(!taken)
                CountCorrect++;
        else
            BTB_insert(ins_ptr);
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

    BTB_init();

    INS_AddInstrumentFunction(Instruction, 0);
    PIN_AddFiniFunction(Fini, 0);

    PIN_StartProgram();

    return 0;
}
