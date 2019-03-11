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

fbt::pmap_copy_page:entry,
fbt::pmap_zero_page:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing/
{
	@["count", probefunc] = count();
	self->ts = timestamp
}

fbt::pmap_copy_page:entry,
fbt::pmap_zero_page:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing
	&& self->ts/
{
	@["total", probefunc] = sum(timestamp - self->ts);
	@["count", probefunc] = count()
}
