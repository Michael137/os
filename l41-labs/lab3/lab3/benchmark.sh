#!/bin/sh

# I miss bash...
sysctl kern.ipc.maxsockbuf=33554432

# I miss bash...
EXE=$1
FLAGS=$2
IPC=$3
MODE=$4
D_SCRIPT=$5
FILE=$6
DRUNS=$7
RUNS=1
TOT_SIZE=16777216
BUF_SIZE=131072

OUT_FILE="${FILE}_${MODE}_${IPC}_${FLAGS}"

echo "Testing IPC object ${IPC} with size ${TOT_SIZE}"
for i in 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	for k in `seq ${DRUNS}`
	do
    	cmd="${EXE} ${FLAGS} -i ${IPC} -b ${i} -t ${TOT_SIZE} ${MODE}"
		echo "Executing ${cmd}"
		echo "Starting DTrace: ${D_SCRIPT}"

		sleep 2 && \
			for j in `seq ${RUNS}`
			do
				# Perform I/O
				${cmd}
			done &
		io_pid=$!

		# Start DTrace here
		benchtmp_file="benchtmp_${OUT_FILE}_${k}"
		dtrace -p $! -s ${D_SCRIPT} -o $benchtmp_file &
		dtrace_pid=$!

		# Wait for I/O to finish
		wait $io_pid

		# Interrupt DTrace
		kill -2 ${dtrace_pid}

	done
	# Format output
	rm -f ${OUT_FILE}_${i}
	for file in benchtmp_${OUT_FILE}_*;
	do
		cat $file | grep -E 'total|count|times' >> ${OUT_FILE}_${i}
		rm $file;
	done
done
