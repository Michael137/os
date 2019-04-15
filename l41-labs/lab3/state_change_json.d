fbt::tcp_state_change:entry
/args[0]->t_inpcb->inp_inc.inc_ie.ie_lport == htons(10141)
	|| args[0]->t_inpcb->inp_inc.inc_ie.ie_fport == htons(10141)/
{
	printf("{ \"time\":\"%u\", \"local_port\":\"%u\", \"foreign_port\":\"%u\", \"previous_tcp_state\":\"%s\", \"tcp_state\":\"%s\" }",
	walltimestamp,
	ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_lport),
	ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_fport),
	tcp_state_string[args[0]->t_state],
	tcp_state_string[args[1]]);

/*	stack(); */
}
