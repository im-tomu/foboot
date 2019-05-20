  .text
  .align 2

#ifdef __riscv64
#define _RISCV_SZPTR 64
#define _RISCV_SZINT 64
#else
/* Our RV64 64-bit routine is equivalent to our RV32 32-bit routine.  */
# define __muldi3 __mulsi3
#define _RISCV_SZPTR 32
#define _RISCV_SZINT 32
#endif

  .globl __muldi3
__muldi3:
  mv     a2, a0
  li     a0, 0
.L1:
  slli   a3, a1, _RISCV_SZPTR-1
  bgez   a3, .L2
  add    a0, a0, a2
.L2:
  srli   a1, a1, 1
  slli   a2, a2, 1
  bnez   a1, .L1
  ret
