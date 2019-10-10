#!/usr/local/bin/bash

PRED=$1
OUT="${PRED}_merged.csv"

rm -f $OUT
touch $OUT

for i in `seq 4 16`
do
	grep "Percentage" "out/tool_${PRED}_${i}.out" | CTR=$i awk '{ print ENVIRON["CTR"]","$2 }' >> $OUT
done
