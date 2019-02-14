/*
 * Invoke as: dtrace -s syscall.d "<exec name>"
 */

syscall:::entry
/execname == $$1/
{
	self->start = timestamp;
	self->insyscall = 1;
}

syscall:::return
/execname == $$1 && self->insyscall != 0/
{
	length = timestamp - self->start;
	@syscall_time[probefunc] = sum(length);
	@totaltime = sum(length);
	self->insyscall = 0;
}

END
{
	printa(@syscall_time);
	printa(@totaltime);
}
