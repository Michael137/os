OUT_FILE=$2

rm ${OUT_FILE}

dtrace -s $1 -o ${OUT_FILE} -x switchrate=5hz -b 50m &
ipc/ipc-static -i tcp -b 1048576 2thread && kill -2 $!
