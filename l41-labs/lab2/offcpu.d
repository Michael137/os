sched:::off-cpu /execname == "ipc-static"/{ self->ts = timestamp; }

sched:::on-cpu /self->ts && execname == "ipc-static"/
{
	@["ns"] = quantize(timestamp - self->ts);
	self->ts = 0;
}
