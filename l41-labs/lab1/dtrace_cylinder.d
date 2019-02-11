fbt::ffs_balloc:entry,
fbt::ffs_alloc:entry,
fbt::ffs_alloccgblk:entry
/execname == "io-static"/
{
	@[stack()] = count()
}
