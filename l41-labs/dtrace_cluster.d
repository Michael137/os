fbt::breadn_flags:entry /execname == "io-static"/ { self->ts = timestamp; }
fbt::breadn_flags:return /self->ts/ {@[execname,"breadn_flags"] = sum(timestamp - self->ts); self->ts = 0; }

fbt::cluster_read:entry /execname == "io-static"/ { self->cts = timestamp; }
fbt::cluster_read:return /self->cts/ {@[execname,"cluster_read"] = sum(timestamp - self->cts); self->cts = 0; }
