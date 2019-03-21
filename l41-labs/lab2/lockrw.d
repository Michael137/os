lockstat:::rw-*
/execname == "ipc-static"/
{
	@locks[probename] = count();
	@stacks[stack()] = count();
}
