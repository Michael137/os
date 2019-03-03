#!/bin/sh

# I miss bash...
sysctl kern.ipc.maxsockbuf=33554432

# I miss bash...
EXE=$1
FLAGS=$2
IPC=$3
MODE=$4
D_SCRIPT=$5
OUT_FILE=$6
RUNS=5
TOT_SIZE=16777216
BUF_SIZE=131072

echo "Testing IPC object ${IPC} with size ${TOT_SIZE}"

for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
    cmd="${EXE} ${FLAGS} -i ${IPC} -b ${i} -t ${TOT_SIZE} ${MODE}"
	echo "Executing ${cmd}"
	echo "Starting DTrace: ${D_SCRIPT}"

	sleep 1 && \
		for j in `seq ${RUNS}`
		do
			# Perform I/O
			${cmd}
		done &
	io_pid=$!

	# Start DTrace here
	dtrace -p $! -s ${D_SCRIPT} -o ${OUT_FILE}_${i} &
	dtrace_pid=$!

	# Wait for I/O to finish
	wait $io_pid

	# Interrupt DTrace
	kill -2 ${dtrace_pid}

	# Format output
done
