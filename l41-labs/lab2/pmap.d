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

/*
fbt::vm_fault_prefault:entry,
*/

fbt::vm_reserv_alloc_page:entry,
fbt::pmap_fault:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing/
{
	@["count", probefunc] = count();
	self->ts = timestamp
}

fbt::vm_reserv_alloc_page:return,
fbt::pmap_fault:return
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing
	&& self->ts/
{
	@["total", probefunc] = sum(timestamp - self->ts);
}
