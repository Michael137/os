dtrace -n 'fbt::pipe_read:entry /execname == ipc-static/ { @ = quantize(((*(struct pipe*)((struct file*)(arg0))->f_data).pipe_state & 0x400) != 0)}' &
