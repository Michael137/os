#!/bin/bash -e

for i in `seq 7 13`
do
	sed "s|PLACEHOLDER|$i|g" sweep.submit.template > "sweep.submit.1bit.$i"
	sed -i "s|SCRIPT|run-1bit|g" "sweep.submit.1bit.$i"
	sed -i "s|ARGUMENTS|$i out/tool_1bit_$i.out /usr/local/benchmarks/dealII_O3 10|g" "sweep.submit.1bit.$i"

	condor_submit "sweep.submit.1bit.$i"
	
	sed "s|PLACEHOLDER|$i|g" sweep.submit.template > "sweep.submit.2bit.$i"
	sed -i "s|SCRIPT|run-2bit|g" "sweep.submit.2bit.$i"
	sed -i "s|ARGUMENTS|$i out/tool_2bit_$i.out /usr/local/benchmarks/dealII_O3 10|g" "sweep.submit.2bit.$i"

	condor_submit "sweep.submit.2bit.$i"

	sed "s|PLACEHOLDER|$i|g" sweep.submit.template > "sweep.submit.adaptive.$i"
	sed -i "s|SCRIPT|run-adaptive|g" "sweep.submit.adaptive.$i"
	sed -i "s|ARGUMENTS|$i out/tool_adaptive_$i.out /usr/local/benchmarks/dealII_O3 10|g" "sweep.submit.adaptive.$i"

	condor_submit "sweep.submit.adaptive.$i"
done
