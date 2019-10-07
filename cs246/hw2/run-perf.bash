#!/bin/bash -e

[[ $# == 2 ]] ||
	{ echo "Usage: $0 EVENT-LIST COMMAND" 2>&1; exit 1; }

declare events=$1
declare command=$2

sudo perf stat -e "$events" "$command" 3>&1 >/dev/null 2>&3

date

# sudo perf list
