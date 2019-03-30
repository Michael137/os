#pragma D option bufsize=3M
#pragma D option bufresize=manual

BEGIN
{
	in_segment = 0;
	wts = vtimestamp
}

fbt::tcp_do_segment:entry
/args[1]->th_sport == htons(10141) ||
	args[1]->th_dport == htons(10141)/
{
	in_segment = 1;

	wts = vtimestamp;
	printf("source:%d ", htons(args[1]->th_sport));
	printf("dest:%d ", htons(args[1]->th_dport));
	printf("Seq:%d ", (unsigned int)args[1]->th_seq);
	printf("Ack:%d ", (unsigned int)args[1]->th_ack);
	printf("Time:%d ", wts);
	trace(tcp_state_string[args[3]->t_state]);
}
