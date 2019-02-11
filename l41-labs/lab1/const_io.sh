#!/bin/sh

./benchmark_io.sh io/io-static "-r -B -q" iofile dtrace_pmap_copy_timing.d rBq_const_io_16m_pmap_copy_timing
./benchmark_io.sh io/io-static "-r -B -q -s" iofile dtrace_pmap_copy_timing.d rBqs_const_io_16m_pmap_copy_timing
./benchmark_io.sh io/io-static "-r -B -q -d" iofile dtrace_pmap_copy_timing.d rBqd_const_io_16m_pmap_copy_timing

./benchmark_io.sh io/io-static "-w -B -q" iofile dtrace_pmap_copy_timing.d wBq_const_io_16m_pmap_copy_timing
./benchmark_io.sh io/io-static "-w -B -q -s" iofile dtrace_pmap_copy_timing.d wBqs_const_io_16m_pmap_copy_timing
./benchmark_io.sh io/io-static "-w -B -q -d" iofile dtrace_pmap_copy_timing.d wBqd_const_io_16m_pmap_copy_timing

./benchmark_io.sh io/io-static "-r -B -q" iofile dtrace_pmap_stack.d rBq_const_io_16m_pmap_stack
./benchmark_io.sh io/io-static "-r -B -q -s" iofile dtrace_pmap_stack.d rBqs_const_io_16m_pmap_stack
./benchmark_io.sh io/io-static "-r -B -q -d" iofile dtrace_pmap_stack.d rBqd_const_io_16m_pmap_stack

./benchmark_io.sh io/io-static "-w -B -q" iofile dtrace_pmap_stack.d wBq_const_io_16m_pmap_stack
./benchmark_io.sh io/io-static "-w -B -q -s" iofile dtrace_pmap_stack.d wBqs_const_io_16m_pmap_stack
./benchmark_io.sh io/io-static "-w -B -q -d" iofile dtrace_pmap_stack.d wBqd_const_io_16m_pmap_stack
