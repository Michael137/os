#!/usr/local/bin/bash

is_dtrace_loaded()
{
	[ `kldstat | grep -Ei 'dtrace' | wc -l` -gt 1 ]
}

load_dtrace_ker_mods() {
	if ! is_dtrace_loaded; then
		echo "loading dtrace modules"
		sudo kldload dtrace
		sudo kldload dtraceall
	fi
}
