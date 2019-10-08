#!/bin/bash -e

PREDICTOR=2level_knobs.cpp make all

HHRT_ENTRIES=`seq 4 16`
PT_ENTRIES=`seq 4 16`
declare EXE=$1
declare TOOL="obj-intel64/hw2.so"
declare OUT_FILE="tool_adaptive.out"

for j in ${PT_ENTRIES};
do
	NUM_PT_ENTRIES=$((2 ** ${j}))
	for i in ${HHRT_ENTRIES};
	do
		NUM_HHRT_ENTRIES=$((2 ** ${i}))
		echo "Writing to ${OUT_FILE}..."
		printf "### ${NUM_HHRT_ENTRIES} ${NUM_PT_ENTRIES} ###\n" >> ${OUT_FILE}
		pin -t "$TOOL" -outfile "tool.out" -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -- "$EXE"
	done
done
