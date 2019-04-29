#ifndef FOBOOSTER_H_
#define FOBOOSTER_H_

#include <stdint.h>
#include <stdbool.h>

#define XXH_NO_LONG_LONG
#define XXH_FORCE_ALIGN_CHECK 0
#define XXH_FORCE_NATIVE_FORMAT 0
#define XXH_PRIVATE_API
#include "xxhash.h"

#define FOBOOSTER_SEED 0xc38b9e66L

struct fobooster_data
{
    uint32_t payload_size;
    uint32_t xxhash;
    uint32_t payload[0];
};

#endif /* FOBOOSTER_H_ */