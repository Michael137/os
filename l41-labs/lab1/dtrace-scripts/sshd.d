syscall::open:entry /execname == "sshd"/ { trace(copyinstr(arg0)); }
