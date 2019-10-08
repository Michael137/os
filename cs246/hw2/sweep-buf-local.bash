#!/bin/bash -e

EXE=$1

./run-pin-local-1bit.bash ${EXE}
./run-pin-local-2bit.bash ${EXE}
