syscall::execve:return
/execname == "io-static"/
{
	self->ts = timestamp
}

syscall::exit:entry
/execname == "io-static"
 && self->ts/
{
	trace(timestamp - self->ts)
}
