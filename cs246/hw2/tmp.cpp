#include <bitset>
#include <iostream>

int main()
{
	std::bitset<4> bits("0001");
	bits =std::bitset<4>(bits.to_ulong() - 1ULL); 
	std::cout << bits << std::endl;
	return bits.to_ulong();
}
