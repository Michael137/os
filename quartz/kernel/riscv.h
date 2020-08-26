#ifndef RISCV_H_IN
#define RISCV_H_IN

#include "types.h"

// Get hart (hardware thread/core) id
inline uint64 r_mhartid()
{
	uint64 x;
	asm ("csrr %0, mhartid" : "=r" (x));

	return x;
}

// Machine-mode status register (mstatus)
// 
// MPP are bits 11-12 in RV64's mstatus
// and hold the previous privilege mode
#define MSTATUS_MPP_MASK (3L << 11)
#define MSTATUS_MPP_M (3L << 11)
#define MSTATUS_MPP_S (1L << 11)
#define MSTATUS_MPP_U (0L << 11)

// Machine-mode interrupt enable
#define MSTATUS_MIE (1L << 3)

inline uint64 r_mstatus()
{
	uint64 x;
	asm ("csrr %0, mstatus" : "=r" (x) );

	return x;
}

inline void w_mstatus(uint64 x)
{
	asm ("csrw mstatus, %0" :: "r" (x));
}

inline void w_mepc(uint64 x)
{
	asm ("csrw mepc, %0" :: "r" (x));
}

// Supervisor status register (sstatus)

// Previous privilege mode (bit 8 of sstatus)
// 1 = Supervisor
// 0 = User
// SPP bit indicates the privilege level at which a hart
// was executing before entering supervisor mode
#define SSTATUS_SPP (1L << 8)

// Supervisor previous interrupt enable
#define SSTATUS_SPIE (1L << 5)

// User previous interrupt enable
#define SSTATUS_UPIE (1L << 4)

// Supervisor interrupt enable
#define SSTATUS_SIE (1L << 1)

// User interrupte enable
#define SSTATUS_UIE (1L << 0)

inline uint64 r_sstatus()
{
	uint64 x;
	asm ("csrr %0, sstatus" : "=r" (x) );
	return x;
}

inline void w_sstatus(uint64 x)
{
	asm ("csrw sstatus, %0" :: "r" (x));
}

// Supervisor Interrupt Registers
// containing information on pending interrupts
inline uint64 r_sip()
{
	uint64 x;
	asm ("csrr %0, sip" : "=r" (x));
	return x;
}

inline void w_sip(uint64 x)
{
	asm ("csrw sip, %0" :: "r" (x));
}

// Supervisor Interrupt Enable
#define SIE_SEIE (1L << 9) // external
#define SIE_STIE (1L << 5) // timer
#define SIE_SSIE (1L << 1) // software

inline uint64 r_sie()
{
	uint64 x;
	asm ("csrr %0, sie" : "=r" (x));
	return x;
}

inline void w_sie(uint64 x)
{
	asm ("csrw sie, %0" :: "r" (x));
}

// Machine-mode interrupt enable
#define MIE_MEIE (1L << 11) // external
#define MIE_MTIE (1L << 7) // timer
#define MIE_MSIE (1L << 3) // software

inline uint64 r_mie()
{
	uint64 x;
	asm ("csrr %0, mie" : "=r" (x));
	return x;
}

inline void w_mie(uint64 x)
{
	asm ("csrw mie, %0" :: "r" (x));
}

// Machine exception delegation
inline uint64 r_medeleg()
{
	uint64 x;
	asm ("csrr %0, medeleg" : "=r" (x));
	return x;
}

inline void w_medeleg(uint64 x)
{
	asm ("csrw medeleg, %0" :: "r" (x));
}

// Machine interrupt delegation
inline uint64 r_mideleg()
{
	uint64 x;
	asm ("csrr %0, mideleg" : "=r" (x));
	return x;
}

inline void w_mideleg(uint64 x)
{
	asm ("csrw mideleg, %0" :: "r" (x));
}

// Thread pointer (tp)
// Holds this core's hartid (core number)
inline uint64 r_tp()
{
	uint64 x;
	asm ("mv %0, tp" : "=r" (x));
}

inline void w_tp(uint64 x)
{
	asm ("mv tp, %0" :: "r" (x));
}

// Machine-mode interrupt vector
inline void w_mtvec(uint64 x)
{
	asm ("csrw mtvec, %0" :: "r" (x));
}

// RISCV's SV39 page table scheme
#define SATP_SV39 (8L << 60)
#define MAKE_SATP(pagetable) (SATP_V39 | (((uint64) pagetable) >> 12))

// Supervisor address trasnlation and protection
// holds the address of the page table
inline void w_satp(uint64 x)
{
	asm ("csrw satp, %0" :: "r" (x));
}

inline uint64 r_satp()
{
	uint64 x;
	asm ("csrr %0, satp" : "=r" (x));
	return x;
}

inline void w_mscratch(uint64 x)
{
	asm ("csrw mscratch, %0" :: "r" (x));
}

#endif // RISCV_H_IN
