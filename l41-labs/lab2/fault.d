syscall::clock_gettime:return
/execname == "ipc-static" && !in_bench/
{
	in_bench = 1
}

syscall::clock_gettime:entry
/execname == "ipc-static" && in_bench/
{
	in_bench = 0
}

fbt::vm_fault:entry
/execname == "ipc-static"
	&& in_bench/
{
	self->ts = vtimestamp;
}

fbt::vm_fault:return
/execname == "ipc-static"
	&& self->ts
	&& in_bench/
{
/*	@faults = quantize(vtimestamp - self->ts); */
	@times["times"] = sum(vtimestamp - self->ts);
	@counts["counts"] = count();
}
