#!/bin/bash

for hrt in `seq 4 16`
do
	OUT="adaptive_merged_${hrt}.csv"
	rm -f $OUT
	touch $OUT

	for pt in `seq 4 16`
	do
		grep "Percentage" "out/tool_adaptive_${pt}_${hrt}.out" | PT=$pt awk '{ print ENVIRON["PT"]","$2 }' >> $OUT
	done
done

for pt in `seq 4 16`
do
	OUT="adaptive_merged_pt_${pt}.csv"
	rm -f $OUT
	touch $OUT

	for hrt in `seq 4 16`
	do
		grep "Percentage" "out/tool_adaptive_${pt}_${hrt}.out" | HHRT=$hrt awk '{ print ENVIRON["HHRT"]","$2 }' >> $OUT
	done
done
