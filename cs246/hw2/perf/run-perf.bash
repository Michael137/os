#!/bin/bash -e

declare events=$1

mkdir out

for i in `seq 1 6`
do
	printf ">>> ${i}\n" >> out/quantum.out
	sudo perf stat -e "$events" /usr/local/benchmarks/libquantum_O3 100 25 3>&1 >/dev/null 2>>out/quantum.out

	printf ">>> ${i}\n" >> out/dealii.out
	sudo perf stat -e "$events" /usr/local/benchmarks/dealII_O3 2 3>&1 >/dev/null 2>>out/dealii.out
done
