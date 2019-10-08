#!/bin/bash -e

PREDICTOR=2bit_knobs.cpp make all

BUF_SZ=`seq 4 16`
declare EXE=$1
declare TOOL="obj-intel64/hw2.so"
declare OUT_FILE="tool_2bit.out"

for j in ${BUF_SZ};
do
	ENTRIES=$((2 ** ${j}))
	echo "Writing to ${OUT_FILE}..."
	printf "### ${ENTRIES} ###\n" >> ${OUT_FILE}
	pin -t "$TOOL" -outfile "tool.out" -bpred_size $ENTRIES -- "$EXE"
done
