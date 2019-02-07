syscall:::entry /execname== "io-static"/ {
	@syscalls= count();self->insyscall= 1;self->start = timestamp;
}

syscall:::return /execname== "io-static" && self->insyscall!= 0/ {
	length = timestamp -self->start; @syscall_time= sum(length);self->insyscall= 0;
}

fbt::trap:entry/execname== "io-static" && self->insyscall== 0/ {
	@traps = count(); self->start = timestamp;
}

fbt::trap:return/execname== "io-static" && self->insyscall== 0/ {
	length = timestamp -self->start; @trap_time= sum(length);
}

END {
	printa(@syscalls); printa(@syscall_time);printa(@traps); printa(@trap_time);
}
