#!/bin/bash -e

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for i in `seq 1 3`
do
	#printf ">>> ${i}" >> "tool_1bit.out"
	# sweep 1bit and store in file
	./run-1bit.bash 7 13 "out/tool_1bit.out_{i}" "/usr/local/benchmarks/dealII_O3" 2

	#printf ">>> ${i}" >> "tool_2bit.out"
	# sweep 2bit and store in file
	./run-2bit.bash 7 13 "out/tool_2bit.out_{i}" "/usr/local/benchmarks/dealII_O3" 2

	#printf ">>> ${i}" >> "tool_adaptive.out"
	# sweep adaptive and store in file
	./run-adaptive.bash 7 13 "out/tool_adaptive.out_{i}" "/usr/local/benchmarks/dealII_O3" 2
done
