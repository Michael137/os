PREDICTORS=knobs.cpp.so

ifeq "$(CONDOR)" ""
	CONDOR=buf
endif

install:
	mv *.cpp.so obj-intel64/

%.cpp.so: %.cpp
	cp $< hw2.cpp
	$(MAKE) -f build.mk clean
	$(MAKE) -f build.mk obj-intel64/hw2.so
	mv obj-intel64/hw2.so $@

all: $(PREDICTORS) install

condor:
	rm -f pin.log
	rm -f tool.out
	rm -f tool_1bit.out
	rm -f tool_2bit.out
	rm -f tool_adaptive.out
	rm -f measure.log
	rm -f measure.err
	rm -f measure.out
	touch pin.log
	touch tool_1bit.out
	touch tool_2bit.out
	touch tool_adaptive.out
	condor_submit "measure-pin-sweep-${CONDOR}.submit"
