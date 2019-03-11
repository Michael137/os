fbt::vm_fault:entry
/execname == "ipc-static"/
{
	self->ts = timestamp
}

fbt::vm_fault:return
/execname == "ipc-static" && self->ts/
{
	@faults = quantize(timestamp - self->ts);
}
