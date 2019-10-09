#!/bin/bash -e

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

date

# sweep 1bit and store in file
./run-1bit.bash 7 9 "test1bit.out" "/usr/local/benchmarks/libquantum_O3" 400 25

# sweep 2bit and store in file
./run-2bit.bash 7 9 "test2bit.out" "/usr/local/benchmarks/libquantum_O3" 400 25

# sweep adaptive and store in file
./run-adaptive.bash 7 9 "testadaptive.out" "/usr/local/benchmarks/libquantum_O3" 400 25

date
