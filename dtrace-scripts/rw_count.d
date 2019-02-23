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

fbt::sys_read:entry
/execname == $$1 && self->in_bench/
{
	@rcnt["reads"] = count();
}

fbt::sys_write:entry
/execname == $$1 && self->in_bench/
{
	@wcnt["writes"] = count();
}
