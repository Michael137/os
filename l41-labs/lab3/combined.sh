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
	for k in `seq 10`
	do
		sysctl net.inet.tcp.hostcache.purgenow=1
		if [ ! -z "${1}" ]; then
			OUT_FILE="combined_${i}_${k}_${1}.log"
		else
			OUT_FILE="combined_${i}_${k}.log"
		fi
		cmd="./auto.sh combined.d ${OUT_FILE} ${1}"

		echo "Executing ${cmd} (run ${k})"
		${cmd}

		sleep 20
		ps | grep dtrace | grep -v grep | awk '{print $1}' | xargs kill -9
	done
done
