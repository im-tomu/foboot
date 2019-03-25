#include "toboot-api.h"
#include "toboot-internal.h"

#define XXH_NO_LONG_LONG
#define XXH_FORCE_ALIGN_CHECK 0
#define XXH_FORCE_NATIVE_FORMAT 0
#define XXH_PRIVATE_API
#include "xxhash.h"

static const struct toboot_configuration *current_config = NULL;

uint32_t tb_first_free_address(void) {
    return 131072;
    /*
    extern uint32_t _eflash;
    extern uint32_t _sdtext;
    extern uint32_t _edtext;
#define PADDR(x) ((uint32_t)&x)
#define PAGE_SIZE 1024
#define PAGE_ROUND_UP(x) ( (((uint32_t)(x)) + PAGE_SIZE-1) & (~(PAGE_SIZE-1)) ) 
    return PAGE_ROUND_UP(PADDR(_eflash) + (PADDR(_edtext) - PADDR(_sdtext)));
#undef PADDR
#undef PAGE_SIZE
#undef PAGE_ROUND_UP
*/
}

uint32_t tb_config_hash(const struct toboot_configuration *cfg) {
    return 0;//XXH32(cfg, sizeof(*cfg) - 4, TOBOOT_HASH_SEED);
}

void tb_sign_config(struct toboot_configuration *cfg) {
    cfg->reserved_hash = tb_config_hash(cfg);
}

int tb_valid_signature_at_page(uint32_t page) {
    const struct toboot_configuration *cfg = (const struct toboot_configuration *)((page * 1024) + 0x94);
    if (cfg->magic != TOBOOT_V2_MAGIC)
        return -1;
    
    uint32_t calc_hash = tb_config_hash(cfg);
    if (calc_hash != cfg->reserved_hash)
        return -2;

    return 0;
}

uint32_t tb_first_free_sector(void) {
    return tb_first_free_address() / 1024;
}

const struct toboot_configuration *tb_get_config(void) {
    uint32_t __app_start__ = 131072;

    // When examining every application in flash, find the newest program
    // with the highest generation counter.
    uint32_t newest_generation = 0;

    // Fake toboot config, for v1 and v0 programs.
    static struct toboot_configuration fake_config;

    if (current_config)
        return current_config;

    // Look for a V2 header
    uint32_t page;
    for (page = 1; page < 65536/1024; page++) {
        if (!tb_valid_signature_at_page(page)) {
            const struct toboot_configuration *test_cfg = (const struct toboot_configuration *)((page * 1024) + 0x94);
            if (test_cfg->reserved_gen > newest_generation) {
                newest_generation = test_cfg->reserved_gen;
                current_config = test_cfg;
            }
        }
    }

    if (current_config)
        return current_config;

    // No V2 header found, so create one.
    
    // Fake V2 magic
    fake_config.magic = TOBOOT_V2_MAGIC;

    if (((*((uint32_t *)(((uint32_t)&__app_start__) + 0x98))) & TOBOOT_V1_MAGIC_MASK) == TOBOOT_V1_MAGIC)
        // Applications that know about Toboot will indicate their block
        // offset by placing a magic byte at offset 0x98.
        // Ordinarily this would be the address offset for IRQ 22,
        // but since there are only 20 IRQs on the EFM32HG, there are three
        // 32-bit values that are unused starting at offset 0x94.
        // We already use offset 0x94 for "disable boot", so use offset 0x98
        // in the incoming stream to indicate flags for Toboot.
        fake_config.start = ((*((uint32_t *)(((uint32_t)&__app_start__) + 0x98))) & TOBOOT_V1_APP_PAGE_MASK) >> TOBOOT_V1_APP_PAGE_SHIFT;
    else
        // Default to offset 0x4000
        fake_config.start = 16;

    // Leave interrupts enabled (and indicate the header is fake)
    fake_config.config = TOBOOT_CONFIG_FLAG_ENABLE_IRQ | TOBOOT_CONFIG_FAKE;

    // Lock out bootloader entry, if the magic value is present
    if (((*((uint32_t *)(((uint32_t)&__app_start__) + 0x94))) & TOBOOT_V1_CFG_MAGIC_MASK) == TOBOOT_V1_CFG_MAGIC)
        fake_config.lock_entry = TOBOOT_LOCKOUT_MAGIC;
    else
        fake_config.lock_entry = 0;

    // Don't erase anything in particular
    fake_config.erase_mask_lo = 0;
    fake_config.erase_mask_hi = 0;

    // Calculate a valid hash
    tb_sign_config(&fake_config);

    return &fake_config;
}

uint32_t tb_generation(const struct toboot_configuration *cfg) {
    if (!cfg)
        return 0;
    return cfg->reserved_gen;
}

__attribute__ ((used, section(".toboot_configuration"))) struct toboot_configuration toboot_configuration = {
    .magic = TOBOOT_V2_MAGIC,

    // The current "generation" flag sits at the same location as the
    // old Toboot "Config" flag.  By setting "reserved_gen" to this value,
    // we can make the V1 bootloader treat V2 images as valid.
    .reserved_gen = TOBOOT_V1_APP_MAGIC,

    .start = 0,
    .config = 0,

    .lock_entry = 0,
    .erase_mask_lo = 0,
    .erase_mask_hi = 0,
    .reserved_hash = 0,
};
