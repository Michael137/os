#!/bin/bash -e

PT_SZ=$1
HHRT_SZ=$2
declare OUT_FILE=$3
declare EXE=$4

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

NUM_PT_ENTRIES=$((2 ** ${PT_SZ}))
NUM_HHRT_ENTRIES=$((2 ** ${HHRT_SZ}))
echo "Writing to ${OUT_FILE}..."
printf "### ${NUM_PT_ENTRIES} ${NUM_HHRT_ENTRIES} ###\n" >> ${OUT_FILE}
pin -t "knobs.cpp.so" -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -predictor 2 -- "$EXE" $5 $6
