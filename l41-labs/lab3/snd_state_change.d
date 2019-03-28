/* From sender to receiver */

fbt::tcp_state_change:entry
/args[0]->t_inpcb->inp_inc.inc_ie.ie_fport == htons(10141)/
{
/*	trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_lport));
	trace(ntohs(args[0]->t_inpcb->inp_inc.inc_ie.ie_fport));*/
	trace(tcp_state_string[args[0]->t_state]);
	trace(tcp_state_string[args[1]]);
	stack();
}
