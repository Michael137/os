####################
#
# Use perf to measure performance of a command with no arguments
#
####################
# script that runs the experiment
executable = run.sh

# command-line arguments to the script
arguments = out/cache_assoc_2.r2.out config-base-2.r2 0 /usr/local/benchmarks/hmmer_O3 /usr/local/benchmarks/inputs/nph3.hmm /usr/local/benchmarks/inputs/swiss41

# no standard input needed this time
# input = measure.in

# files in which to save standard output and standard error
output = measure-log-2.r2.out
error = measure-log-2.r2.err

# file for condor’s statistics about the job’s execution
log = measure-log-2.r2.log

# need exclusive use of execution host with 96 logical processors
# request_cpus = 96

should_transfer_files = YES
when_to_transfer_output = ON_EXIT
transfer_input_files = ../obj-intel64/hw3.so,out,config-base-2.r2
transfer_output_files = out

# submit a job with the parameters given above
queue
