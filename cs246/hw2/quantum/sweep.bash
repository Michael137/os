#!/bin/bash -e

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

for i in `seq 1 2`
do
	printf ">>> ${i}" >> "tool_1bit.out"
	# sweep 1bit and store in file
	./run-1bit.bash "tool_1bit.out" "/usr/local/benchmarks/libquantum_O3" 400 25

	printf ">>> ${i}" >> "tool_2bit.out"
	# sweep 2bit and store in file
	./run-2bit.bash "tool_2bit.out" "/usr/local/benchmarks/libquantum_O3" 400 25

	printf ">>> ${i}" >> "tool_adaptive.out"
	# sweep adaptive and store in file
	./run-adaptive.bash "tool_adaptive.out" "/usr/local/benchmarks/libquantum_O3" 400 25
done
