#!/bin/bash -e

BUF_SZ=$1
declare OUT_FILE=$2
declare EXE=$3

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

NUM_PT_ENTRIES=$((2 ** ${BUF_SZ}))
for i in `seq 7 13`
do
	NUM_HHRT_ENTRIES=$((2 ** ${i}))
	echo "Writing to ${OUT_FILE}..."
	printf "### ${NUM_HHRT_ENTRIES} ###\n" >> ${OUT_FILE}
	pin -t "knobs.cpp.so" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -predictor 2 -- "$EXE" $4 $5
done
