#!/bin/sh

EXE=$1
FLAGS=$2
FILE=$3
D_SCRIPT=$4
OUT_FILE=$5
RUNS=1
FILE_SIZE=16777216

echo "Creating benchmark file of size ${FILE_SIZE}"
${EXE} -c -t ${FILE_SIZE} ${FILE}
echo "Starting benchmark with: ${FLAGS} on ${FILE}"

# I miss bash...
for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	cmd="${EXE} ${FLAGS} -b ${i} -t ${FILE_SIZE} ${FILE}"
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
	dtrace -p $! -s ${D_SCRIPT} > ${OUT_FILE}_${i} 2>&1 &
	dtrace_pid=$!

	# Wait for I/O to finish
	wait $io_pid

	# Interrupt DTrace
	kill -2 ${dtrace_pid}

	# Format output
done
