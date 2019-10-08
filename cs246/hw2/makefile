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
