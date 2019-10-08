#!/bin/bash -e

#PREDICTOR=2level_knobs.cpp make all

HHRT_ENTRIES=`seq 4 16`
PT_ENTRIES=`seq 4 16`
declare EXE=$1
declare TOOL=hw2.so

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

ls

for j in ${PT_ENTRIES};
do
	NUM_PT_ENTRIES=$((2 ** ${j}))
	for i in ${HHRT_ENTRIES};
	do
		NUM_HHRT_ENTRIES=$((2 ** ${i}))
		#OUT_FILE="data/tool.out_${NUM_HHRT_ENTRIES}_${NUM_PT_ENTRIES}"
		#OUT_FILE="tool.out_${NUM_HHRT_ENTRIES}_${NUM_PT_ENTRIES}"
		OUT_FILE="tool.out"
		echo "Writing to ${OUT_FILE}..."
		printf "### ${NUM_HHRT_ENTRIES} ${NUM_PT_ENTRIES} ###\n" >> ${OUT_FILE}
		pin -t "$TOOL" -outfile "tool.out" -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -bpred_size $NUM_PT_ENTRIES -- "$EXE"
	done
done
