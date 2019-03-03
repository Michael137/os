dtrace -n 'fbt::pipe_write:entry /execname == ipc-static/ { print(*(struct uio*)(arg1))}' &
