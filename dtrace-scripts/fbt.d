syscall::clock_gettime:return
/execname == $$1 && !self->in_bench/
{
	self->in_bench = 1;
	self->bts = vtimestamp;
}

syscall::clock_gettime:entry
/execname == $$1 && self->in_bench/
{
	@bench_time["vtime"] = sum(vtimestamp - self->bts);
	self->in_bench = 0;
}

/*fbt::*page*:entry*/
/*fbt:::entry*/
/*fbt::vm_*:entry*/
/* pipe + low buf size for socket call:vm_fault_quick_hold_pages */
fbt::vm_fault:entry,
fbt::vm_page*:entry,
fbt::pmap*:entry
/execname == $$1 && self->in_bench/
{
	self->pts = timestamp;
}

fbt::vm_fault:return,
fbt::vm_page*:return,
fbt::pmap*:return
/execname == $$1 && self->in_bench/
{
	@fbt[probefunc] = sum(timestamp - self->pts);
}

END
{
	printa(@fbt);
	printa(@bench_time);
	printa(@wake);
}
