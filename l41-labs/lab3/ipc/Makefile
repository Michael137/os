all: ipc-static ipc-dynamic ipc-no-nagle

CFLAGS=-DWITH_PMC -Wall

ipc-static: ipc.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc.c -static \
	    -lpmc -lpthread

ipc-dynamic: ipc.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc.c -dynamic \
	    -lpmc -lpthread

ipc-no-nagle: ipc-no-nagle.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc-no-nagle.c -static \
	    -lpmc -lpthread
