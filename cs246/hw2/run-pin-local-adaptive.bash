#!/bin/bash -e

HHRT_ENTRIES=`seq 7 13`
PT_ENTRIES=`seq 7 13`
declare EXE=$1
declare TOOL="obj-intel64/knobs.cpp.so"
declare OUT_FILE="tool_adaptive.out"

#for j in ${PT_ENTRIES};
for j in 9
do
	NUM_HHRT_ENTRIES=$((2 ** ${j}))
	for i in ${HHRT_ENTRIES}
	do
		NUM_PT_ENTRIES=$((2 ** ${i}))
		echo "Writing to ${OUT_FILE}..."
		printf "### ${NUM_HHRT_ENTRIES} ${NUM_PT_ENTRIES} ###\n" >> ${OUT_FILE}
		pin -t "$TOOL" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -predictor 2 -- "$EXE" $2 $3
	done
done
