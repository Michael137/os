#!/bin/bash -e

declare OUT_FILE=$1
declare CONFIG_NAME=$2
declare EXE=$3

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

echo "Writing to ${OUT_FILE}..."
pin -t "hw3.so" -outfile ${OUT_FILE} -config ${CONFIG_NAME} -- "$EXE" $4 $5
