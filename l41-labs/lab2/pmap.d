syscall::clock_gettime:return
/execname == "ipc-static" && !in_bench/
{
	in_bench = 1;
}

syscall::clock_gettime:entry
/execname == "ipc-static" && in_bench/
{
	in_bench = 0;
}

fbt::vm_fault_prefault:entry,
fbt::pmap_fault:entry
/execname == "ipc-static"/
{
	@["count", probefunc] = count()
}
