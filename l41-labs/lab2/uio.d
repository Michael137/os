fbt::uiomove_faultflag:entry
/execname == "ipc-static"/
{
	self->fs = timestamp
}

fbt::uiomove_faultflag:entry
/execname == "ipc-static"
	&& self->fs/
{
	@uioff["faultflag_total"] = sum(timestamp - self->fs)
}

fbt::uiomove_fromphys:entry
/execname == "ipc-static"/
{
	self->phys = timestamp
}

fbt::uiomove_fromphys:entry
/execname == "ipc-static"
	&& self->phys/
{
	@uioff["fromphys_total"] = sum(timestamp - self->phys)
}
