#include "defs.h"
#include "types.h"
#include "riscv.h"

void main();
void timerinit();

__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

uint64 mscratch0[NCPU * 32];

extern void timervec();

void
start()
{
	unsigned long x = r_mstatus();
	x &= ~MSTATUS_MPP_MASK;
	x |= MSTATUS_MPP_S;
	w_mstatus(x);

	w_mepc((uint64) main);

	w_satp(0);

	w_medeleg(0xffff);
	w_mideleg(0xffff);
	w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

	//timerinit();

	int id = r_mhartid();
	w_tp(id);

	asm volatile("mret");
}

/*
void timerinit()
{
	int id = r_mhartid();

	int interval = 1e6;
	*(uint64*) CLINT_MTIMECMP(id) = *(uint64*) CLINT_MTIME + interval;

	uint64* scratch = &mscratch0[32 * id];
	scratch[4] = CLINT_MTIMECMP(id);
	scratch[5] = interval;
	w_mscratch((uint64) scratch);

	w_mtvec((uint64) timervec);

	w_mstatus(r_mstatus() | MSTATUS_MIE);

	w_mie(r_mie() | MIE_MTIE);
}
*/
