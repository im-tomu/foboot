#ifndef FOBOOSTER_H_
#define FOBOOSTER_H_

#include <stdint.h>
#include <stdbool.h>

#define XXH_NO_LONG_LONG
#define XXH_FORCE_ALIGN_CHECK 0
#define XXH_FORCE_NATIVE_FORMAT 0
#define XXH_PRIVATE_API
#include "xxhash.h"

#define BOOSTER_SEED 0xc38b9e66L
#define BOOSTER_SIGNATURE 0x4260fa37

struct booster_data
{
    uint32_t xxhash;
};

#endif /* FOBOOSTER_H_ */