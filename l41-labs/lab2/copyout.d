dtrace -n 'fbt::copyout_nosmap_erms:entry /execname == ipc-static/ { @[stack()] = count() }' &
