#!/bin/sh

# I miss bash...
EXE=$1
FLAGS=$2
FILE=$3
D_SCRIPT=$4
OUT_FILE=$5
RUNS=2
FILE_SIZE=16777216
BUF_SIZE=16384

echo "Creating benchmark file of size ${FILE_SIZE}"
${EXE} -c -t ${FILE_SIZE} ${FILE}
echo "Starting benchmark with: ${FLAGS} on ${FILE}"

# Use for constant IO
for i in 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
#for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	# Use for constant IO
	${EXE} -c -t ${i} ${FILE}
	cmd="${EXE} ${FLAGS} -b ${BUF_SIZE} -t ${i} ${FILE}"

	# cmd="${EXE} ${FLAGS} -b ${i} -t ${FILE_SIZE} ${FILE}"
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
