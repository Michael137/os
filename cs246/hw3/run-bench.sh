#!/bin/bash -e

for i in `1 2 4 8`
do
	TEMPLATE="config.submit.template"
	SUBMIT_NAME="config.submit.${i}"
	CONFIG_NAME="config-base-${i}"
	LOG_NAME="measure-log-${i}"
	sed "s|PLACEHOLDER|${i}|g" config-base-template > $CONFIG_NAME
	sed "s|CONFIG|${CONFIG_NAME}|g" $TEMPLATE > $SUBMIT_NAME
	sed -i "s|LOG|${LOG_NAME}|g" $SUBMIT_NAME
	sed -i "s|ARGUMENTS|${i} out/cache_assoc_${i}.out /usr/local/benchmarks/libquantum_O3 400 25|g" $SUBMIT_NAME

	# condor_submit "sweep.submit.${i}"
done
