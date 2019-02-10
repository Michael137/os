syscall::clock_gettime:return
/execname == "io-static" && !self->in_benchmark/
{
	self->in_benchmark = 1;
}

syscall::clock_gettime:entry
/execname == "io-static" && self->in_benchmark/
{
	self->in_benchmark = 0;
}

fbt::pmap_copy_pages:entry
/self->in_benchmark/
{
	@traces[stack()] = count()
}
