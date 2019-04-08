OUT_FILE=$2

rm ${OUT_FILE}

dtrace -s $1 -o ${OUT_FILE} &
ipc/ipc-static -i tcp -b 1048576 2thread && kill -2 $!
