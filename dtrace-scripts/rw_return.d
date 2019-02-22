syscall::read:entry
/execname == "ipc-static" && !self->in_read/
{
	self->in_read = 1;
	@["read_in"] = quantize(arg2);
}

syscall::read:return
/execname == "ipc-static" && self->in_read/
{
	self->in_read = 0;
	@["read_out"] = quantize((ssize_t)arg0);
}

syscall::write:entry
/execname == "ipc-static" && !self->in_write/
{
	self->in_write = 1;
	@["write_in"] = quantize(arg2);
}

syscall::write:return
/execname == "ipc-static" && self->in_write/
{
	self->in_write = 0;
	@["write_out"] = quantize((ssize_t)arg0);
}
