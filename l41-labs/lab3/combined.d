#pragma D option bufsize=3M
#pragma D option bufresize=manual

fbt::tcp_do_segment:entry
/args[1]->th_sport == htons(10141)/
{
	printf("tx->rx ");
	printf("source:%d ", htons(args[1]->th_sport));
	printf("dest:%d ", htons(args[1]->th_dport));
	printf("Seq:%d ", (unsigned int)args[1]->th_seq);
	printf("Ack:%d ", (unsigned int)args[1]->th_ack);
	printf("Time:%d ", walltimestamp);
	trace(tcp_state_string[args[3]->t_state]);
}

fbt::tcp_do_segment:entry
/args[1]->th_dport == htons(10141)/
{
	printf("rx->tx ");
	printf("source:%d ", htons(args[1]->th_sport));
	printf("dest:%d ", htons(args[1]->th_dport));
	printf("Seq:%d ", (unsigned int)args[1]->th_seq);
	printf("Ack:%d ", (unsigned int)args[1]->th_ack);
	printf("Time:%d ", walltimestamp);
	trace(tcp_state_string[args[3]->t_state]);
}
