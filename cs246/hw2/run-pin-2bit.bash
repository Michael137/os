#!/bin/bash -e

BUF_SZ=`seq 4 16`
declare EXE=$1
declare TOOL=2bit_knobs.cpp.so
declare OUT_FILE="tool_2bit.out"

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for j in ${BUF_SZ};
do
	ENTRIES=$((2 ** ${j}))
	echo "Writing to ${OUT_FILE}..."
	printf "### ${ENTRIES} ###\n" >> ${OUT_FILE}
	pin -t "$TOOL" -outfile $OUT_FILE -bpred_size $ENTRIES -- "$EXE" $2 $3
done
