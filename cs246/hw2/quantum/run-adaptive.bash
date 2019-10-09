#!/bin/bash -e

BUF_SZ_BEGIN=$1
BUF_SZ_END=$2
BUF_SZ=`seq $BUF_SZ_BEGIN $BUF_SZ_END` # Used to sweep both HHRT and PT

declare OUT_FILE=$3
declare EXE=$4

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for j in ${BUF_SZ}
do
	NUM_HHRT_ENTRIES=$((2 ** ${j}))
	for i in ${BUF_SZ}
	do
		NUM_PT_ENTRIES=$((2 ** ${i}))
		echo "Writing to ${OUT_FILE}..."
		printf "### ${NUM_HHRT_ENTRIES} ${NUM_PT_ENTRIES} ###\n" >> ${OUT_FILE}
		pin -t "knobs.cpp.so" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -predictor 2 -- "$EXE" $5 $6
	done
done
