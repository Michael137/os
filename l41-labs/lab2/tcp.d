fbt::*ip*:entry,
fbt::*tcp*:entry 
/execname == "ipc-static"/ 
{ 
	self->ts = timestamp;
	@calls[probefunc] = count();
}

fbt::*ip*:return,
fbt::*tcp*:return 
/execname == "ipc-static" && self->ts/ 
{ 
	@times[probefunc] = sum(timestamp - self->ts);
}

END
{
	printa(@calls);
	printa(@times);
}
