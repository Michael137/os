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

fbt::uiomove_faultflag:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing/
{
	self->fs = timestamp
}

fbt::uiomove_faultflag:return
/execname == "ipc-static"
	&& self->fs
	&& in_bench
	&& !stop_tracing/
{
	@uioff["faultflag_total"] = sum(timestamp - self->fs)
}

fbt::uiomove_fromphys:entry
/execname == "ipc-static"
	&& in_bench
	&& !stop_tracing/
{
	self->phys = timestamp
}

fbt::uiomove_fromphys:return
/execname == "ipc-static"
	&& self->phys
	&& in_bench
	&& !stop_tracing/
{
	@uioff["fromphys_total"] = sum(timestamp - self->phys)
}
