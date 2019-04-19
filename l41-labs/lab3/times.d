BEGIN
{
	ts = 0;
	in_bench = 0;
}

syscall::clock_gettime:return
/!in_bench && execname == "ipc-static"/
{
	in_bench = 1
}

fbt::*tcp*:entry
/in_bench && execname == "intr"/
{
	ts = timestamp;
}

fbt::*tcp*:return
/in_bench && execname == "intr"/
{
	trace(timestamp - ts);
}

syscall::clock_gettime:entry
/in_bench && execname == "ipc-static"/
{
	in_bench = 0;
	exit(0);
}
