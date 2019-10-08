#!/bin/bash -e

EXE=$1

./run-pin-1bit.bash ${EXE} $2 $3
./run-pin-2bit.bash ${EXE} $2 $3
