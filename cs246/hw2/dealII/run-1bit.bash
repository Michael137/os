#!/bin/bash -e

BUF_SZ_BEGIN=$1
BUF_SZ_END=$2
BUF_SZ=`seq $BUF_SZ_BEGIN $BUF_SZ_END`
declare OUT_FILE=$3
declare EXE=$4

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

echo $BUF_SZ

for j in ${BUF_SZ}
do
	ENTRIES=$((2 ** ${j}))
	echo "Writing to ${OUT_FILE}..."
	printf "### ${ENTRIES} ###\n" >> ${OUT_FILE}
	pin -t "knobs.cpp.so" -outfile $OUT_FILE -bpred_size $ENTRIES -predictor 0 -- "$EXE" $5 $6
done
