syscall::clock_gettime:return
/execname == "ipc-static" && !in_bench/
{
	in_bench = 1
}

syscall::clock_gettime:entry
/execname == "ipc-static" && in_bench/
{
	in_bench = 0;
	stop_tracing = 1;
}

syscall::read:entry,
syscall::write:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing
	&& !self->in_syscall/
{
	self->start = timestamp;
	self->in_syscall = 1;
}

syscall::read:return,
syscall::write:return
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing
	&& self->in_syscall/
{
	@total["total", probefunc] = sum(timestamp - self->start);
	self->start = 0;
	self->in_syscall = 0;
}
