# D Language scripts
D_ffs_read_time = """
syscall::clock_gettime:return
/execname == "io-static" && !self->in_benchmark/
{
    self->in_benchmark = 1;
}

syscall::clock_gettime:entry
/execname == "io-static" && self->in_benchmark/
{
    self->in_benchmark = 0;
}

fbt::ffs_read:entry
/self->in_benchmark/
{
    self->ts = vtimestamp;
}
fbt::ffs_read:return
/self->ts && self->in_benchmark/
{
    @[id] = sum(vtimestamp - self->ts);
    self->ts = 0;
}
"""

D_program_time = """
syscall::execve:return
/execname == "io-static" && self->ts/
{
    trace(vtimestamp - self->ts)
}

syscall::exit:entry
/execname == "io-static"/
{
    self->ts = vtimestamp;
}
"""

D_buf_strategy_freq = """
syscall::clock_gettime:return
/execname == "io-static" && !self->in_benchmark/
{
    self->in_benchmark = 1;
}

syscall::clock_gettime:entry
/execname == "io-static" && self->in_benchmark/
{
    self->in_benchmark = 0;
}

fbt::bufstrategy:entry
/self->in_benchmark/
{
    @num = count()
}
"""

D_cache_flag = """
syscall::clock_gettime:return
/execname == "io-static" && !self->in_benchmark/
{
    self->in_benchmark = 1;
}

syscall::clock_gettime:entry
/execname == "io-static" && self->in_benchmark/
{
    self->in_benchmark = 0;
}

fbt::bufwait:entry
/self->in_benchmark/
{
    @ = quantize(((struct buf*)arg1)->b_iocmd == 0x01 /* BIO_READ */)
}
"""
