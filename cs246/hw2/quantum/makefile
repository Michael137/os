clean_test:
	rm -f test1bit.out
	rm -f test2bit.out
	rm -f testadaptive.out
	rm -f measure_test.log
	rm -f measure_test.err
	rm -f measure_test.out

condor_test:
	touch test1bit.out
	touch test2bit.out
	touch testadaptive.out
	touch measure_test.log
	touch measure_test.err
	touch measure_test.out
	condor_submit test.submit

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
condor_test: clean_test condor_test

.PHONY:
sweep: clean condor
