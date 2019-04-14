/* On receiver */

fbt::tcp_state_change:entry
/args[0]->t_inpcb->inp_inc.inc_ie.ie_fport == htons(10141)/
{
/*	trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_lport));
	trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_fport));*/
	trace(tcp_state_string[args[0]->t_state]);
	trace(tcp_state_string[args[1]]);
	stack();
}

fbt::syncache_add:entry
/args[3]->inp_inc.inc_ie.ie_fport == htons(10141)/
{
	trace(probefunc);
	printf("[%s", (args[2])->th_flags & TH_FIN ? "FIN|" : "");
	printf("%s", (args[2])->th_flags & TH_SYN ? "SYN|" : "");
	printf("%s", (args[2])->th_flags & TH_RST ? "RST|" : "");
	printf("%s", (args[2])->th_flags & TH_PUSH ? "PUSH|" : "");
	printf("%s", (args[2])->th_flags & TH_ACK ? "ACK|" : "");
	printf("%s", (args[2])->th_flags & TH_URG ? "URG|" : "");
	printf("%s", (args[2])->th_flags & TH_ECE ? "ECE|" : "");
	printf("%s]", (args[2])->th_flags & TH_CWR ? "CWR" : "");
	stack();
}

fbt::syncache_expand:entry
/args[0]->inc_ie.ie_fport == htons(10141)/
{
	trace(probefunc);
	printf("[%s", (args[2])->th_flags & TH_FIN ? "FIN|" : "");
	printf("%s", (args[2])->th_flags & TH_SYN ? "SYN|" : "");
	printf("%s", (args[2])->th_flags & TH_RST ? "RST|" : "");
	printf("%s", (args[2])->th_flags & TH_PUSH ? "PUSH|" : "");
	printf("%s", (args[2])->th_flags & TH_ACK ? "ACK|" : "");
	printf("%s", (args[2])->th_flags & TH_URG ? "URG|" : "");
	printf("%s", (args[2])->th_flags & TH_ECE ? "ECE|" : "");
	printf("%s]", (args[2])->th_flags & TH_CWR ? "CWR" : "");
	stack();
}

fbt::tcp_do_segment:entry
/args[1]->th_dport == htons(10141)/
{
	trace(tcp_state_string[args[3]->t_state]);
	printf("[%s", (args[1])->th_flags & TH_FIN ? "FIN|" : "");
	printf("%s", (args[1])->th_flags & TH_SYN ? "SYN|" : "");
	printf("%s", (args[1])->th_flags & TH_RST ? "RST|" : "");
	printf("%s", (args[1])->th_flags & TH_PUSH ? "PUSH|" : "");
	printf("%s", (args[1])->th_flags & TH_ACK ? "ACK|" : "");
	printf("%s", (args[1])->th_flags & TH_URG ? "URG|" : "");
	printf("%s", (args[1])->th_flags & TH_ECE ? "ECE|" : "");
	printf("%s]", (args[1])->th_flags & TH_CWR ? "CWR" : "");
}
