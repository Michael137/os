clean:
	rm -f *.out
	rm -f *.log
	rm -f *.err

condor:
	touch tool_1bit.out
	touch tool_2bit.out
	touch tool_adaptive.out
	touch pin.log
	touch measure.log
	touch measure.err
	touch measure.out
	condor_submit measure.submit

all: clean condor
