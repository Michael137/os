#!/bin/sh

# I miss bash...
sysctl kern.ipc.maxsockbuf=33554432
ipfw pipe config 1 delay 0
ipfw pipe config 2 delay 0
ipfw add 1 pipe 1 tcp from any 10141 to any via lo0
ipfw add 2 pipe 2 tcp from any to any 10141 via lo0
ifconfig lo0 mtu 1500

for i in 0 5 10 15 20 25 30 35 40
do
	ipfw pipe config 1 delay ${i}
	ipfw pipe config 2 delay ${i}
	sysctl net.inet.tcp.hostcache.purgenow=1
	OUT_FILE="combined_${i}.log"
	cmd="./auto.sh combined.d ${OUT_FILE}"

	echo "Executing ${cmd}"
	${cmd}

#	file_busy_cmd="fuser -f ${OUT_FILE} | wc -w"
#	while [ file_busy_cmd != 0 ]
#	do
#		echo "sleeping" && sleep 2
#	done
	sleep 20
	ps | grep dtrace | grep -v grep | awk '{print $1}' | xargs kill -9
done
