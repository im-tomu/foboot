#include <stdint.h>
void csr_writeb(uint8_t value, uint32_t addr)
{
        *((volatile uint8_t *)addr) = value;
}

uint8_t csr_readb(uint32_t addr)
{
        return *(volatile uint8_t *)addr;
}

void csr_writew(uint16_t value, uint32_t addr)
{
        *((volatile uint16_t *)addr) = value;
}

uint16_t csr_readw(uint32_t addr)
{
        return *(volatile uint16_t *)addr;
}

void csr_writel(uint32_t value, uint32_t addr)
{
        *((volatile uint32_t *)addr) = value;
}

uint32_t csr_readl(uint32_t addr)
{
        return *(volatile uint32_t *)addr;
}
