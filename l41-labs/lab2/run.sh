#!/bin/sh

# uiomove
./benchmark.sh ipc/ipc-static "" pipe 1thread uio.d uio.out 10
./benchmark.sh ipc/ipc-static "" local 1thread uio.d uio.out 10
./benchmark.sh ipc/ipc-static "" pipe 2thread uio.d uio.out 10
./benchmark.sh ipc/ipc-static "" pipe 2proc uio.d uio.out 10
./benchmark.sh ipc/ipc-static "" local 2thread uio.d uio.out 10
./benchmark.sh ipc/ipc-static "" local 2proc uio.d uio.out 10
./benchmark.sh ipc/ipc-static "-s" local 2thread uio.d uio.out 10
./benchmark.sh ipc/ipc-static "-s" local 2proc uio.d uio.out 10

# Off-cpu
# ./benchmark.sh ipc/ipc-static "" local 2proc offcputime.d offcpu.out 10
# ./benchmark.sh ipc/ipc-static "" local 2thread offcputime.d offcpu.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2proc offcputime.d offcpu.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2thread offcputime.d offcpu.out 10
# ./benchmark.sh ipc/ipc-static "" pipe 2proc offcputime.d offcpu.out 10
# ./benchmark.sh ipc/ipc-static "" pipe 2thread offcputime.d offcpu.out 10
 
# prefault/vm_fault/pmap_fault
./benchmark.sh ipc/ipc-static "" pipe 2proc pmap.d pmap.out 10
./benchmark.sh ipc/ipc-static "" pipe 2thread pmap.d pmap.out 10
./benchmark.sh ipc/ipc-static "-s" local 2proc pmap.d pmap.out 10
./benchmark.sh ipc/ipc-static "-s" local 2thread pmap.d pmap.out 10
./benchmark.sh ipc/ipc-static "" local 2thread pmap.d pmap.out 10
./benchmark.sh ipc/ipc-static "" local 2proc pmap.d pmap.out 10

# rw
# ./benchmark.sh ipc/ipc-static "" pipe 1thread rw_count.d rw.out 3
# ./benchmark.sh ipc/ipc-static "" pipe 2thread rw_count.d rw.out 3
# ./benchmark.sh ipc/ipc-static "" local 1thread rw_count.d rw.out 3
# ./benchmark.sh ipc/ipc-static "" local 2thread rw_count.d rw.out 3
# ./benchmark.sh ipc/ipc-static "-s" local 1thread rw_count.d rw.out 3
# ./benchmark.sh ipc/ipc-static "-s" local 2thread rw_count.d rw.out 3

# Sys
# ./benchmark.sh ipc/ipc-static "" pipe 2proc syscall.d sys.out 10
# ./benchmark.sh ipc/ipc-static "" pipe 2thread syscall.d sys.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2proc syscall.d sys.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2thread syscall.d sys.out 10
# ./benchmark.sh ipc/ipc-static "" local 2thread syscall.d sys.out 10
# ./benchmark.sh ipc/ipc-static "" local 2proc syscall.d sys.out 10

# Lock
#./benchmark.sh ipc/ipc-static "" pipe 2thread lock.d lock.out 10
#./benchmark.sh ipc/ipc-static "" pipe 2proc lock.d lock.out 10
#./benchmark.sh ipc/ipc-static "" local 2thread lock.d lock.out 10
#./benchmark.sh ipc/ipc-static "" local 2proc lock.d lock.out 10
#./benchmark.sh ipc/ipc-static "-s" local 2thread lock.d lock.out 10
#./benchmark.sh ipc/ipc-static "-s" local 2proc lock.d lock.out 10

# pmap_copy_page, zero_page
# ./benchmark.sh ipc/ipc-static "" pipe 2proc page.d page.out 10
# ./benchmark.sh ipc/ipc-static "" pipe 2thread page.d page.out 10
# ./benchmark.sh ipc/ipc-static "" local 2proc page.d page.out 10
# ./benchmark.sh ipc/ipc-static "" local 2thread page.d page.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2proc page.d page.out 10
# ./benchmark.sh ipc/ipc-static "-s" local 2thread page.d page.out 10
