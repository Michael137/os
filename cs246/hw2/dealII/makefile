clean:
	rm -f test1bit.out
	rm -f test2bit.out
	rm -f testadaptive.out
	rm -f measure_test.log
	rm -f measure_test.err
	rm -f measure_test.out

condor:
	rm -rf out
	mkdir out
	touch out/tool_1bit.out
	touch out/tool_2bit.out
	touch out/tool_adaptive.out
	touch out/measure_sweep.log
	touch out/measure_sweep.err
	touch out/measure_sweep.out
	condor_submit sweep.submit

.PHONY:
sweep: clean condor
