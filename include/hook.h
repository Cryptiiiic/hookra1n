//
// Created by cryptic on 8/23/22.
//

#ifndef CHECKRA1N_HOOK_H
#define CHECKRA1N_HOOK_H

#include <stdint.h>

static uint64_t slide = 0;

static uint64_t t8015_stage2_address = 0;
static uint64_t memcpy_address = 0;

static void *t8015_stage2_jumpback_address = NULL;
static void *jump_back = NULL;

int setup_hooks(void);

static void t8015_stage2_hook_tramp(void);



#endif //CHECKRA1N_HOOK_H
