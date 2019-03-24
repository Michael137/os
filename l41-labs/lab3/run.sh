#!/bin/sh

# State-transitions
./benchmark.sh ipc/ipc-static "-B -q" tcp 2thread transitions.d transitions.out 12
