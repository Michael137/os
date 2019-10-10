#!/bin/bash -e

# Adaptive file names: <name>.PTSIZE_HHRTSIZE

for i in `seq 7 13`
do
	sed "s|PLACEHOLDER|${i}|g" sweep.condor.template > "sweep.submit.1bit.${i}"
	sed -i "s|SCRIPT|run-1bit|g" "sweep.submit.1bit.${i}"
	sed -i "s|ARGUMENTS|${i} out/tool_1bit_${i}.out /usr/local/benchmarks/libquantum_O3 400 25|g" "sweep.submit.1bit.${i}"

	condor_submit "sweep.submit.1bit.${i}"
	
	sed "s|PLACEHOLDER|${i}|g" sweep.condor.template > "sweep.submit.2bit.${i}"
	sed -i "s|SCRIPT|run-2bit|g" "sweep.submit.2bit.${i}"
	sed -i "s|ARGUMENTS|${i} out/tool_2bit_${i}.out /usr/local/benchmarks/libquantum_O3 400 25|g" "sweep.submit.2bit.${i}"

	condor_submit "sweep.submit.2bit.${i}"

	for j in `seq 7 13`
	do
		sed "s|PLACEHOLDER|${i}_${j}|g" sweep.condor.adaptive.template > "sweep.submit.adaptive.${i}_${j}"
		sed -i "s|SCRIPT|run-adaptive|g" "sweep.submit.adaptive.${i}_${j}"
		sed -i "s|ARGUMENTS|${i} $j out/tool_adaptive_${i}_${j}.out /usr/local/benchmarks/libquantum_O3 400 25|g" "sweep.submit.adaptive.${i}_${j}"

		condor_submit "sweep.submit.adaptive.${i}_${j}"
	done
done
