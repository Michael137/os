#!/bin/bash -e

HHRT_ENTRIES=`seq 7 13`
PT_ENTRIES=`seq 7 13`
declare OUT_FILE=$1
declare EXE=$2

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
		pin -t "knobs.cpp.so" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -predictor 2 -- "$EXE" $3 $4
	done
done
