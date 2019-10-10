#!/bin/bash -e

BUF_SZ=$1
declare OUT_FILE=$2
declare EXE=$3

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

ENTRIES=$((2 ** ${BUF_SZ}))
echo "Writing to ${OUT_FILE}..."
printf "### ${ENTRIES} ###\n" >> ${OUT_FILE}
pin -t "knobs.cpp.so" -outfile $OUT_FILE -bpred_size $ENTRIES -predictor 0 -- "$EXE" $4 $5
