#!/bin/bash -e

rm -f config-base-*
rm -f measure-log-*
rm -f config.submit.*
rm -f out/*

## Without victim cache
for i in 1 2 4 8
do
	for j in `seq 1 6`
	do
		TEMPLATE="config.submit-template"
		SUBMIT_NAME="config.submit.${i}.r${j}"
		CONFIG_NAME="config-base-${i}.r${j}"
		LOG_NAME="measure-log-${i}.r${j}"
		OUT_FILE="out/cache_assoc_${i}.r${j}.out"
		sed "s|PLACEHOLDER|${i}|g" config-base.template > $CONFIG_NAME
		sed -i "s|VICTIM|1|g" $CONFIG_NAME
		sed "s|CONFIG|${CONFIG_NAME}|g" $TEMPLATE > $SUBMIT_NAME
		sed -i "s|LOG|${LOG_NAME}|g" $SUBMIT_NAME
		sed -i "s|ARGUMENTS|${OUT_FILE} ${CONFIG_NAME} 0 /usr/local/benchmarks/libquantum_O3 400 25|g" ${SUBMIT_NAME}

		condor_submit $SUBMIT_NAME
	done
done

# With victim cache
for i in 1 2 3 4 5 6 7 8
do
	for j in `seq 1 6`
	do
		TEMPLATE="config.submit-template"
		SUBMIT_NAME="config.submit.${i}.r${j}-victim"
		CONFIG_NAME="config-base-${i}.r${j}-victim"
		LOG_NAME="measure-log-${i}.r${j}-victim"
		OUT_FILE="out/victim_${i}.r${j}_l1_direct.out"
		sed "s|PLACEHOLDER|1|g" config-base.template > $CONFIG_NAME
		sed -i "s|VICTIM|${i}|g" $CONFIG_NAME
		sed "s|CONFIG|${CONFIG_NAME}|g" $TEMPLATE > $SUBMIT_NAME
		sed -i "s|LOG|${LOG_NAME}|g" $SUBMIT_NAME
		sed -i "s|ARGUMENTS|${OUT_FILE} ${CONFIG_NAME} 1 /usr/local/benchmarks/libquantum_O3 400 25|g" ${SUBMIT_NAME}

		condor_submit $SUBMIT_NAME
	done
done

# With victim cache
for i in 1 2 3 4 5 6 7 8
do
	for j in `seq 1 6`
	do
		TEMPLATE="config.submit-template"
		SUBMIT_NAME="config.submit.${i}.r${j}_l8_direct-victim"
		CONFIG_NAME="config-base-${i}.r${j}_l8_direct-victim"
		LOG_NAME="measure-log-${i}.r${j}_l8_direct-victim"
		OUT_FILE="out/victim_${i}.r${j}_l8_direct.out"
		sed "s|PLACEHOLDER|8|g" config-base.template > $CONFIG_NAME
		sed -i "s|VICTIM|${i}|g" $CONFIG_NAME
		sed "s|CONFIG|${CONFIG_NAME}|g" $TEMPLATE > $SUBMIT_NAME
		sed -i "s|LOG|${LOG_NAME}|g" $SUBMIT_NAME
		sed -i "s|ARGUMENTS|${OUT_FILE} ${CONFIG_NAME} 1 /usr/local/benchmarks/libquantum_O3 400 25|g" ${SUBMIT_NAME}

		condor_submit $SUBMIT_NAME
	done
done