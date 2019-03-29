OUT_FILE=test.log

sudo rm ${OUT_FILE}

sudo dtrace -s $1 -o ${OUT_FILE} &
ipc/ipc-static -i tcp -b 1048576 2thread && sudo kill -2 $!
sudo cat ${OUT_FILE}
