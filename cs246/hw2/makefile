all:
	cp 2bit.cpp hw2.cpp
	$(MAKE) -f build.mk clean
	$(MAKE) -f build.mk obj-intel64/hw2.so

test:
	pin -t obj-intel64/hw2.so -- /bin/ls
