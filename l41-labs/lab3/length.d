#pragma D option bufsize=3M
#pragma D option bufresize=manual

BEGIN
{
	in_segment = 0;
	wts = walltimestamp
}

fbt::tcp_do_segment:entry
/args[1]->th_sport == htons(10141)/
{
	in_segment = 1;

	/*printf("Time: %ld",((walltimestamp - wts) / 1000000000));*/
	wts = walltimestamp;
	printf("Seq:%d ", (unsigned int)args[1]->th_seq);
	printf("Ack:%d ", (unsigned int)args[1]->th_ack);
	printf("Time:%d ", wts);
	trace(tcp_state_string[args[3]->t_state]);
}

/*
fbt::tcp_do_segment:return
/in_segment != 0/
{
	in_segment = 0;
}
*/

/*
tcp:::send
/in_segment != 0/
{
	printf("Length: %d", (uint32_t)((*args[2]).ip_plength));
}
*/
