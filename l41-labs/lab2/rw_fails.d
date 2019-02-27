syscall::clock_gettime:return
/execname == "ipc-static" && self->in_bench == 0/
{
	self->in_bench = 1;
}

syscall::clock_gettime:entry
/execname == "ipc-static" && self->in_bench != 0/
{
	self->in_bench = 0
}

syscall::read:return
/execname == "ipc-static" && (ssize_t)arg0 == -1/
{
        @reads[stack()] = count();
}

syscall::write:return
/execname == "ipc-static" && (ssize_t)arg0 == -1/
{
        @writes[stack()] = count();
}

END
{
    printa(@reads);
    printa(@writes);
}
