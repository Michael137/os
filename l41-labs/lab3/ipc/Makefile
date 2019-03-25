all: ipc-static ipc-dynamic ipc-static-nonblock ipc-static-nosleep

CFLAGS=-DWITH_PMC -Wall

ipc-static: ipc.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc.c -static \
	    -lpmc -lpthread

ipc-dynamic: ipc.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc.c -dynamic \
	    -lpmc -lpthread

ipc-static-nonblock: ipc-nonblock.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc-nonblock.c -static \
	    -lpmc -lpthread

ipc-static-nosleep: ipc-nosleep.c
	cc ${CFLAGS} -o ${.TARGET} -DPROGNAME=\"${.TARGET}\" ipc-nosleep.c -static \
	    -lpmc -lpthread
