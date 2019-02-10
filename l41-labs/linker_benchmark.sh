#!/bin/sh

EXE=$1
FLAGS=$2
FILE=$3
FILENAME=$4
RUNS=12
FILE_SIZE=16777216

echo "Creating benchmark file of size ${FILE_SIZE}"
${EXE} -c -t ${FILE_SIZE} ${FILE}
echo "Starting benchmark with: ${FLAGS} on ${FILE}"

# I miss bash...
for i in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
do
	OUT_FILE=${FILENAME}_${i}
	truncate -s 0 ${OUT_FILE}
	# real
	# user
	# sys
	## sys+user == actual CPU time
	cmd="time -p ${EXE} ${FLAGS} -b ${i} -t ${FILE_SIZE} ${FILE}"
	echo "Executing ${cmd}"

	for j in `seq ${RUNS}`
	do
		# Perform I/O
		${cmd} 2>&1 | tail -2 | cut -d' ' -f2 >> "${OUT_FILE}"
		printf "\n" >> "${OUT_FILE}"
	done
	awk -v r=${RUNS} '{ sum += $1 } END { print sum / r }' ${OUT_FILE}
done
