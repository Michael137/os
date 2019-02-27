syscall::read:entry
/execname == "ipc-static"/
{
	self->ts = timestamp;
	self->in = (size_t)arg2;
}

syscall::read:return
/execname == "ipc-static" && self->ts && (ssize_t)arg0 == -1/
{
	@succeeded = quantize(timestamp - self->ts);
}

syscall::read:return
/execname == "ipc-static" && self->ts && (ssize_t)arg0 != -1/
{
	@failed = quantize(timestamp - self->ts);
}

END
{
    printa(@succeeded);
    printa(@failed);
}
