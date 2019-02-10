#!/bin/sh

EXE=$1
FLAGS=$2
FILE=$3
D_SCRIPT=$4
OUT_FILE=$5
RUNS=1

echo "Starting benchmark with: ${FLAGS} on ${FILE}"

# I miss bash...
for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	cmd="${EXE} ${FLAGS} -b ${i} -t 16777216 ${FILE}"
	echo "Executing ${cmd}"
	echo "Starting DTrace: ${D_SCRIPT}"

	for j in `seq ${RUNS}`
	do
		# Perform I/O
		${cmd}
	done &

	# Start DTrace here
	sudo dtrace -p $! -s ${D_SCRIPT} > ${OUT_FILE}_${i} 2>&1 &
	dtrace_pid=$!

	# Interrupt DTrace
	sudo kill -2 ${dtrace_pid}

	# Format output
done
