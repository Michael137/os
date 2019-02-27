sudo dtrace -n fbt::*mbuf*:entry /execname == "ipc-static"/ { @[probefunc] = count() }
