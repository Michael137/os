#!/bin/bash -e

PREDICTOR=2level_knobs.cpp make all

HHRT_ENTRIES=`seq 4 16`
PT_ENTRIES=`seq 4 16`

for j in $PT_ENTRIES;
do
	NUM_PT_ENTRIES=$((2 ** ${j}))
	for i in $HHRT_ENTRIES;
	do
		NUM_HHRT_ENTRIES=$((2 ** ${i}))
		OUT_FILE="data/tool.out_${NUM_HHRT_ENTRIES}_${NUM_PT_ENTRIES}"
		echo "Writing to ${OUT_FILE}..."
		pin -t obj-intel64/hw2.so -outfile $OUT_FILE -hhrt_sz $NUM_HHRT_ENTRIES -pt_sz $NUM_PT_ENTRIES -- /bin/ls
	done
done
