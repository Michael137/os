#include <iostream>

template<int W>
class Shape
{
	public:
		int width;
	public:
		Shape() : width(10) {}
		int get_width() { return width; }
};

template<int R, int W>
class Circle : public Shape<W>
{
public:
	//Circle() : Shape<W>() {}
	int this_width() { return this->width; }
};

int main()
{
	Shape<10> s;
	std::cout << s.get_width() << std::endl;

	Circle<10,20> c;
	std::cout << c.this_width() << std::endl;
}
