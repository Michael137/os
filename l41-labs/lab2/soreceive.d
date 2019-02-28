/*
	Notable code path/fields:
		1. For socketpair the call chain is:
			sys_read
			kern_readv
			dofileread
			fo_read
			soo_read
			soreceive
			pru_soreceive
			soreceive_generic(?)
			pru_rcvd(?)
			uipc_rcvd(?)
		2. Maximum socket buffer size is indicated by field:
			u_int sb_hiwat
*/

fbt::soreceive_generic:entry
/execname == "ipc-static"/
{
	print(((struct sockbuf)((struct socket*)arg0)->so_rcv));
}
