/*
 * Invoke as: dtrace -s syscall.d "<exec name>"
 */
syscall::clock_gettime:return
/execname == "ipc-static" && !self->in_bench/
{
	self->in_bench = 1
}

syscall::clock_gettime:entry
/execname == "ipc-static" && self->in_bench/
{
	self->in_bench = 0
}

syscall:::entry
/execname == "ipc-static" && self->in_bench && probefunc != "clock_gettime"/
{
	@syscalls["syscall_count"] = count();
	self->start = timestamp;
	self->insyscall = 1;
}

syscall:::return
/execname == "ipc-static" && self->insyscall != 0/
{
	length = timestamp - self->start;
	@syscall_total["syscall_total"] = sum(length);
	@sys_br["br",probefunc] = sum(length);
	self->insyscall = 0;
}

fbt::abort_handler:entry
/execname == "ipc-static" && self->insyscall == 0/
{
	@traps["trap_count"] = count();
	self->start = timestamp;
}

fbt::abort_handler:return
/execname == "ipc-static" && self->insyscall == 0/
{
	length = timestamp - self->start;
	@trap_total["trap_total"] = sum(length);
	@trap_br["br", probefunc] = sum(length);
}
