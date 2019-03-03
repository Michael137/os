dtrace -n 'fbt::pipe_write:entry /execname == ipc-static/ { print(*(struct pipe*)((struct pipe*)((struct file*)(arg0))->f_data)->pipe_peer )}' &
