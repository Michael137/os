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

syscall::read:entry
/execname == "ipc-static" && self->in_bench/
{
        self->in = (size_t)arg2;
}

syscall::read:return
/execname == "ipc-static" && self->in_bench/
{
        self->out = (ssize_t)arg0;
        @reads[self->in, self->out] = count();
}

syscall::write:entry
/execname == "ipc-static" && self->in_bench/
{
        self->in_write = 1;
        self->in = (size_t)arg2;
}

syscall::write:return
/execname == "ipc-static" && self->in_bench/
{
        self->in_write = 0;
        self->out = (ssize_t)arg0;
        @writes[self->in, self->out] = count();
}

END
{
    printa(@reads);
    printa(@writes);
}
