#!/bin/bash -e

BUF_SZ=`seq 7 13`
declare OUT_FILE=$1
declare EXE=$2

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for j in ${BUF_SZ};
do
	ENTRIES=$((2 ** ${j}))
	echo "Writing to ${OUT_FILE}..."
	printf "### ${ENTRIES} ###\n" >> ${OUT_FILE}
	pin -t "knobs.cpp.so" -outfile $OUT_FILE -bpred_size $ENTRIES -predictor 1 -- "$EXE" $3 $4
done
