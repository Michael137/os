ifeq "$(PREDICTOR)" ""
	PREDICTOR=2level_knobs.cpp
endif

all:
	cp $(PREDICTOR) hw2.cpp
	$(MAKE) -f build.mk clean
	$(MAKE) -f build.mk obj-intel64/hw2.so

test:
	pin -t obj-intel64/hw2.so -hhrt_sz 256 -pt_sz 4096 -- /bin/ls
	#pin -t obj-intel64/hw2.so -- /bin/ls

condor:
	rm -f pin.log
	rm -f tool.out
	rm -f measure.log
	rm -rf measure.err
	rm -rf measure.out
	touch pin.log
	touch tool.out
	condor_submit measure-pin.submit
