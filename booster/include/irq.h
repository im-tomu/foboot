#ifndef __IRQ_H
#define __IRQ_H

#ifdef __cplusplus
extern "C" {
#endif

#define CSR_MSTATUS_MIE 0x8
#define CSR_IRQ_MASK 0xBC0
#define CSR_IRQ_PENDING 0xFC0
#define CSR_DCACHE_INFO 0xCC0

#ifndef csrr
#define csrr(reg) ({ unsigned long __tmp; \
	asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
	__tmp; })
#endif

#ifndef csrs
#define csrs(reg, bit) ({ \
	if (__builtin_constant_p(bit) && (unsigned long)(bit) < 32) \
		asm volatile ("csrrs x0, " #reg ", %0" :: "i"(bit)); \
	else \
		asm volatile ("csrrs x0, " #reg ", %0" :: "r"(bit)); })
#endif

#ifndef csrc
#define csrc(reg, bit) ({ \
	if (__builtin_constant_p(bit) && (unsigned long)(bit) < 32) \
		asm volatile ("csrrc x0, " #reg ", %0" :: "i"(bit)); \
	else \
		asm volatile ("csrrc x0, " #reg ", %0" :: "r"(bit)); })
#endif

static inline unsigned int irq_getie(void)
{
	return (csrr(mstatus) & CSR_MSTATUS_MIE) != 0;
}

static inline void irq_setie(unsigned int ie)
{
	if(ie) csrs(mstatus,CSR_MSTATUS_MIE); else csrc(mstatus,CSR_MSTATUS_MIE);
}

static inline unsigned int irq_getmask(void)
{
	unsigned int mask;
	asm volatile ("csrr %0, %1" : "=r"(mask) : "i"(CSR_IRQ_MASK));
	return mask;
}

static inline void irq_setmask(unsigned int mask)
{
	asm volatile ("csrw %0, %1" :: "i"(CSR_IRQ_MASK), "r"(mask));
}

static inline unsigned int irq_pending(void)
{
	unsigned int pending;
	asm volatile ("csrr %0, %1" : "=r"(pending) : "i"(CSR_IRQ_PENDING));
	return pending;
}

#ifdef __cplusplus
}
#endif

#endif /* __IRQ_H */
