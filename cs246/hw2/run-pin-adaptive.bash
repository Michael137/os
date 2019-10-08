#!/bin/bash -e

HHRT_ENTRIES=`seq 4 16`
PT_ENTRIES=`seq 4 16`
declare EXE=$1
declare TOOL="2level_knobs.cpp.so"
declare OUT_FILE="tool_adaptive.out"

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for j in ${PT_ENTRIES};
do
	NUM_PT_ENTRIES=$((2 ** ${j}))
	for i in ${HHRT_ENTRIES};
	do
		NUM_HHRT_ENTRIES=$((2 ** ${i}))
		echo "Writing to ${OUT_FILE}..."
		printf "### ${NUM_HHRT_ENTRIES} ${NUM_PT_ENTRIES} ###\n" >> ${OUT_FILE}
		pin -t "$TOOL" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -- "$EXE" $2 $3
	done
done
