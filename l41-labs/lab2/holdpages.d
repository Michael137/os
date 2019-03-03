dtrace -n 'fbt::vm_fault_quick_hold_pages:entry /execname == ipc-static/ { @[(vm_size_t)arg2] = count() }' &
