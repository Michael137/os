syscall::clock_gettime:return
/execname == "ipc-static" && !self->in_benchmark/
{
	self->ts = timestamp;
	self->vts = vtimestamp;
	self->wts = walltimestamp;
	self->in_benchmark = 1;
}

syscall::clock_gettime:entry
/execname == "ipc-static" && self->in_benchmark/
{
	diff = timestamp - self->ts;
	vdiff = vtimestamp - self->vts;
	wdiff = walltimestamp - self->wts;
	self->in_benchmark = 0;
}

END
{
	printf("times:");
	printf("time: %d", diff );
	printf("vtime: %d", vdiff);
	printf("wtime: %d", wdiff);
}
