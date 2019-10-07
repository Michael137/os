// Standard system library include files
#include <iostream>
#include <fstream>

// Required for using Pin API calls and defined data types
#include "pin.H"

// The running count of instructions is kept here
// Your work: You may need more counters for different instruction types...
UINT32 icount_total = 0;
UINT32 icount_load = 0;
UINT32 icount_store = 0;
UINT32 icount_branch = 0;
UINT32 icount_call = 0;

KNOB<std::string> KnobOutFile(KNOB_MODE_WRITEONCE,   "pintool",
	    "outfile", "tool.out", "Output file for the pintool");
//ofstream ofile;
std::ostream * ofile = &std::cerr;

// This prints what the Pin Tool does
INT32 Usage()
{
	std::cerr << "This pin tool counts the number of instructions.\n\n";
	std::cerr << KNOB_BASE::StringKnobSummary() << std::endl;

	return -1;
}

// This function is called whenever the program calls the exit() function
VOID Fini(INT32 code, VOID *v)
{
	*ofile << "Total number of instructions executed = " << icount_total << '\n';
	*ofile << "\tLoads caused: " << icount_load << '\n';
	*ofile << "\tStores caused: " << icount_store << '\n';
	*ofile << "\tControl Flow: " << icount_branch + icount_call  << '\n';
	*ofile << "\t\tBranches: " << icount_branch << '\n';
	*ofile << "\t\tCalls: " << icount_call << '\n';
	*ofile << std::endl;
}

/****** ANALYSIS FUNCTIONS ******/
// Analysis function:: This function is called before every instruction is executed
// Your work: Extend this analysis or write new Analysis functions...
VOID docount(INS ins )
{
	// This function counts call, branch, load, and store instructions.
	// A read/write that occurred in the operands of a call or a branch
	// are also counted. This could be changed by guarding the
	// load/store counters with en "else" branch
	icount_total++;

	// NB: Per latest documentation INS_IsBranchOrCall(ins) is deprecated
	if(INS_IsCall(ins))
		icount_call++;
	else if(INS_IsBranch(ins)) 
		icount_branch++;

	// NB: an instruction can cause both a read and a write
	//     usually in the operands
	//     So count both and don't use if-else
	if(INS_IsMemoryRead(ins))
		icount_load++;
	if(INS_IsMemoryWrite(ins))
		icount_store++;
}

// Instrumentation function:: Pin calls this function every time a new instruction is encountered
VOID Instruction(INS ins, VOID *v)
{
	// Insert a call to docount() before every instruction
	INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR) docount, IARG_PTR, ins, IARG_END);
}

// argc, argv are the entire command line, including pin -t <toolname> -- ...
int main(int argc, char * argv[])
{
	// Initialize pin
	if( PIN_Init(argc, argv) )
	{
	    return Usage();
	}

	std::string fileName = KnobOutFile.Value();
	
	if (!fileName.empty()) { ofile = new std::ofstream(fileName.c_str());}
	//*ofile.open(KnobOutFile.Value());

	// Register Instruction to be called to instrument instructions
	INS_AddInstrumentFunction(Instruction, 0);

	// Called at the end of the program
	PIN_AddFiniFunction(Fini, 0);

	// Start the program, never returns
	PIN_StartProgram();

	return 0;
}
