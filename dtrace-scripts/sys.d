syscall::clock_gettime:entry
/execname == "ipc-static" && self->in_bench == 0/
{
    self->in_bench = 1
}

syscall::clock_gettime:return
/execname == "ipc-static" && self->in_bench != 0/
{
    self->in_bench = 0
}

syscall:::entry
/execname == "ipc-static"/
{
    @syscalls["syscall_count"] = count();
    self->start = timestamp;
    self->insyscall = 1;
}

syscall:::return
/execname == "ipc-static" && self->insyscall != 0/
{
    length = timestamp - self->start;
    @syscall_times[probefunc] = sum(length);
    @syscall_total["syscall_total"] = sum(length);
    self->insyscall = 0;
}

fbt::trapsignal:entry
/execname == "ipc-static" && self->insyscall == 0/
{
    @traps["trap_count"] = count();
    self->start = timestamp;
}

fbt::trapsignal:return
/execname == "ipc-static" && self->insyscall == 0/
{
    length = timestamp - self->start;
    @trap_total["trap_total"] = sum(length);
}

END
{
    printa(@syscall_times);

    printf("syscalls:"); printa(@syscalls);
    printf("total_syscalls:"); printa(@syscall_total);
    printf("traps:"); printa(@traps);
    printf("total_traps:"); printa(@trap_total);
}
