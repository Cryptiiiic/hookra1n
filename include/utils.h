//
// Created by cryptic on 8/23/22.
//

#ifndef CHECKRA1N_UTILS_H
#define CHECKRA1N_UTILS_H

#include <stdint.h>

extern size_t stage2_shellcode_size;
extern FILE *stage2_shellcode_file;
extern uint64_t stage2_shellcode;

void shellcode_setup(void);
void stage2_shellcode_setup(void);

#endif //CHECKRA1N_UTILS_H
