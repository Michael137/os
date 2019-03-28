/* From receiver to sender */

#pragma D option bufsize=3M
#pragma D option bufresize=manual

fbt::tcp_do_segment:entry
/args[1]->th_dport == htons(10141)/
{
	trace((unsigned int)args[1]->th_seq);
	trace((unsigned int)args[1]->th_ack);
	trace(walltimestamp);
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
