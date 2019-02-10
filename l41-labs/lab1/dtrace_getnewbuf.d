fbt::getnewbuf:entry
/execname == "io-static"/
{
	self->rts = timestamp;
}

fbt::ffs_read:return
/self->rts/
{
	@ffs_read[probefunc] = sum(timestamp - self->rts);
	@num = count();
}
