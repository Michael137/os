/*
 * Invoke as: dtrace -s syscall.d "<exec name>"

syscall:::entry
/execname == "ipc-static"/
{
	@[probefunc] = count()
}

*/

syscall::pipe2:entry
/execname == "ipc-static"/
{
	@[stack()] = count();
}
