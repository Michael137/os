#ifndef _LIBK_MEMLAYOUT_H_IN
#define _LIBK_MEMLAYOUT_H_IN

#include <stdint.h>

#define KERNEL_START_PADDR ((uint32_t)&kernel_phys_start)
#define KERNEL_END_PADDR ((uint32_t)&kernel_phys_end)

#define KERNEL_START_VADDR ((uint32_t)&kernel_virt_start)
#define KERNEL_END_VADDR ((uint32_t)&kernel_virt_end)

// Exposed in linker.ld
extern uint32_t kernel_virtual_start;
extern uint32_t kernel_virtual_end;
extern uint32_t kernel_physical_start;
extern uint32_t kernel_physical_end;

#endif // _LIBK_MEMLAYOUT_H_IN
