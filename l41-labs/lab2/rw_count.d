syscall::read:entry
/execname == "ipc-static"/
{
	@["count", probefunc] = count()
}

syscall::write:entry
/execname == "ipc-static"/
{
	@["count", probefunc] = count()
}
