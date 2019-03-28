/* From sender to receiver */

fbt::tcp_do_segment:entry
/args[1]->th_sport == htons(10141)/
{
	@flags[tcp_state_string[args[3]->t_state],
			args[1]->th_flags] = count()
}
