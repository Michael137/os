fbt::pipe_read:entry
/execname == "ipc-static" && !self->in_uio/
{
	self->in_uio = 1
}

fbt::pipe_read:return
/execname == "ipc-static" && self->in_uio/
{
	self->in_uio = 0
}

fbt::uiomove_fromphys:entry
/execname == "ipc-static"
	&& self->in_uio/
{
	@ = count()
}
