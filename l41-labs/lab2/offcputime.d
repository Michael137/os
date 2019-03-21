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

sched:::off-cpu
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing/
{
	self->start = timestamp;
}

sched:::on-cpu
/self->start
	&& (timestamp - self->start)
	&& in_bench
	&& !stop_tracing
/
{
/*	@times = quantize(timestamp - self->start); */
	@total["total"] = sum(timestamp - self->start);
	/* @stacks[stack()] = count(); */
	@count["count"] = count();
	self->start = 0
}
