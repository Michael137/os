#!/bin/sh

 ./benchmark.sh io/io-static "-r -B -q -s" iofile dtrace_pmap.d rBqs_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-r -B -q -d" iofile dtrace_pmap.d rBqd_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-r -B -q -d -s" iofile dtrace_pmap.d rBqds_const_io_16m_pmap
# 
#  ./benchmark.sh io/io-static "-w -B -q -s" iofile dtrace_pmap.d wBqs_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-w -B -q -d" iofile dtrace_pmap.d wBqd_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-w -B -q -d -s" iofile dtrace_pmap.d wBqds_const_io_16m_pmap

#  ./benchmark.sh io/io-static "-r -B -q -s" iofile dtrace_bread.d rBqs_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-r -B -q -d" iofile dtrace_bread.d rBqd_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-r -B -q -d -s" iofile dtrace_bread.d rBqds_const_io_16m_pmap
# 
#  ./benchmark.sh io/io-static "-w -B -q -s" iofile dtrace_bread.d wBqs_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-w -B -q -d" iofile dtrace_bread.d wBqd_const_io_16m_pmap
#  ./benchmark.sh io/io-static "-w -B -q -d -s" iofile dtrace_bread.d wBqds_const_io_16m_pmap
