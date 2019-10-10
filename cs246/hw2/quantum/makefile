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
	rm -f sweep.submit.*

condor:
	rm -rf out
	mkdir out
	./sweep.bash

.PHONY:
condor_test: clean_test condor_test

.PHONY:
sweep: clean condor
