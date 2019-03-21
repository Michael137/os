dtrace -n syscall::read:return /execname == "ipc-static"/ { @calls = quantize(arg0)}
