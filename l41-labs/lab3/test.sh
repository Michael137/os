OUT_FILE=test.log

sudo dtrace -s $1 -o ${OUT_FILE} &
ipc/ipc-static -i tcp -b 1048576 2thread && sudo kill -2 $!
cat ${OUT_FILE}
