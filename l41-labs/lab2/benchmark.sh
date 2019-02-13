#!/bin/sh

sysctl kern.ipc.maxsockbuf=33554432

# I miss bash...
EXE=$1
FLAGS=$2
IPC=$3
MODE=$4
RUNS=1
TOT_SIZE=16777216
BUF_SIZE=131072

echo "Creating IPC object ${IPC} with size ${TOT_SIZE}"

for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	cmd="${EXE} ${FLAGS} -i ${IPC} -b ${i} -t ${TOT_SIZE} ${MODE}"

	echo "Executing ${cmd}"

	for j in `seq ${RUNS}`
	do
		${cmd}
	done
done
