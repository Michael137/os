fbt::*pmap*:entry,
fbt::*page*:entry,
fbt::*copy*:entry
/execname== $$1/
{
	@traces[probefunc] = count();
	self->ts = timestamp;
}

fbt::*pmap*:return,
fbt::*page*:return,
fbt::*copy*:return
/execname== $$1/
{
    @traces[probefunc] = count();
    @times[probefunc] = sum(timestamp - self->ts);
}

END
{
	printa(@traces);
	printa(@times);
}
