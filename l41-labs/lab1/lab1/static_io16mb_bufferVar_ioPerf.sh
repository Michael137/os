#!/bin/bash

for ctr in 1 2 4 8 16 32 64 128 256 512 1024 4096 8192 16384 32768 65536
do
	buf=$((512 * (2 ^ $ctr)))
	echo $buf
	../io/io-static -r -B -d -q -t $buf iofile
done
