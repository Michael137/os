#!/bin/bash -e

[[ $# == 2 ]] ||
	{ echo "Usage: $0 EVENT-LIST COMMAND" 2>&1; exit 1; }

declare tool=$1
declare command=$2

export PIN_ROOT=/opt/intel/pin
export PATH=$PIN_ROOT:$PATH

date

pin -t "$tool" -- "$command" 400 25

date

