#ifndef BB_SPI_H_
#define BB_SPI_H_

#include <stdint.h>

void spiPause(void);
void spiBegin(void);
void spiEnd(void);

int spiRead(uint32_t addr, uint8_t *data, unsigned int count);
int spiIsBusy(void);
int spiBeginErase4(uint32_t erase_addr);
int spiBeginErase32(uint32_t erase_addr);
int spiBeginErase64(uint32_t erase_addr);
int spiBeginWrite(uint32_t addr, const void *data, unsigned int count);
void spiEnableQuad(void);

uint32_t spiId(void);

int spiWrite(uint32_t addr, const uint8_t *data, unsigned int count);
uint8_t spiReset(void);
int spiInit(void);

void spiHold(void);
void spiUnhold(void);
void spiSwapTxRx(void);

void spiFree(void);

#endif /* BB_SPI_H_ */
