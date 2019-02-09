io:::start
/execname == "io-static"/
{
	start[arg0] = timestamp;
}

io:::done
/this->start = start[arg0] &&
 execname == "io-static"/
{
	@["ns"] = quantize(timestamp - this->start);
	start[arg0] = 0;
}
