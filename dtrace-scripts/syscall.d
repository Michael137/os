/*
 * Invoke as: dtrace -s syscall.d "<exec name>"
 */
syscall::clock_gettime:return
/execname == $$1 && !self->in_bench/
{
	self->in_bench = 1
}

syscall::clock_gettime:entry
/execname == $$1 && self->in_bench/
{
	self->in_bench = 0
}

syscall:::entry
/execname == $$1 && self->in_bench && probefunc != "clock_gettime"/
{
	@syscalls = count();
	self->start = timestamp;
	self->insyscall = 1;
}

syscall:::return
/execname == $$1 && self->insyscall != 0/
{
	length = timestamp - self->start;
	@syscall_times[probefunc] = sum(length);
/*	@syscall_counts[probefunc] = count(); */
	@syscall_total = sum(length);
	self->insyscall = 0;
}

fbt::trap:entry
/execname == $$1 && self->insyscall == 0/
{
	@traps = count();
	self->start = timestamp;
}

fbt::trap:return
/execname == $$1 && self->insyscall == 0/
{
	length = timestamp - self->start;
	@trap_total = sum(length);
}

fbt::*page*:entry
/execname == $$1 && self->in_bench/
{
	self->pts = timestamp;
}

fbt::*page*:return
/execname == $$1 && self->in_bench/
{
	@fbt[probefunc] = sum(timestamp - self->pts);
}

END
{
	printa(@syscall_times);
	printa(@fbt);

	printf("syscalls:\n"); printa(@syscalls); printa(@syscall_total);
	printf("traps:\n"); printa(@traps); printa(@trap_total);
}
