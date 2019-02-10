fbt::ffs_read:entry
/execname == "io-static"/
{
	self->rts = timestamp;
	self->in_ffs = 1;
}

fbt::ffs_read:return
/self->rts/
{
	@ffs_read[probefunc] = sum(timestamp - self->rts);
	self->rts = 0;
	self->in_ffs = 0;
}

fbt::breadn_flags:entry
/execname == "io-static"/
{
	self->bts = timestamp;
}

fbt::breadn_flags:return
/self->bts/
{
	@bread[probefunc] = sum(timestamp - self->bts);
	self->bts = 0;
}

fbt::vn_io_fault_pgmove:entry
/execname == "io-static"/
{
	self->ts = timestamp;
}

fbt::vn_io_fault_pgmove:return
/self->ts/
{
	@pmap[probefunc] = sum(timestamp - self->ts);
	self->ts = 0;
}
