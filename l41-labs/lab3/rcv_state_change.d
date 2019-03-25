/* From receiver to sender */

fbt::tcp_state_change:entry
/args[0]->t_inpcb->inp_inc.inc_ie.ie_lport == htons(10141)/
{
	/*trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_lport));
	trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_fport));*/
	trace(tcp_state_string[args[0]->t_state]);
	trace(tcp_state_string[args[1]]);
	/*printf("%s", (args[0])->t_flags & TF_RST ? "RST|" : "");*/
	printf("[%s", (args[0])->t_flags & 0x000001 ? "ACKNOW|" : "");
	printf("%s", (args[0])->t_flags & 0x000010 ? "SENTFIN|" : "");
	printf("%s", (args[0])->t_flags & 0x000400 ? "NEEDSYN|" : "");
	printf("%s", (args[0])->t_flags & 0x000800 ? "NEEDFIN|" : "");
	printf("%s", (args[0])->t_flags & 0x80000000 ? "FASTOPEN|" : "");
	printf("%s", (args[0])->t_flags & 0x1000000 ? "TSO|" : "");
	printf("%s", (args[0])->t_flags & 0x2000000 ? "TOE|" : "");
	printf("%s", (args[0])->t_flags & 0x8000000 ? "CWR|" : "");
	printf("%s", (args[0])->t_flags & 0x10000000 ? "ECE|" : "");
	printf("%s]", (args[0])->t_flags & 0x20000000 ? "CONGRECOVERY" : "");
}
