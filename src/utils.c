//
// Created by cryptic on 8/23/22.
//

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <utils.h>

#if __aarch64__
#else

void shellcode_setup(void) {
    stage2_shellcode_setup();
}

void stage2_shellcode_setup(void) {
    const char *stage2_path = getenv("HOOKRA1N_STAGE2_PATH");
    assert(stage2_path && "[FATAL_ERROR]: HOOKRA1N_STAGE2_PATH is not set!");
    if(!stage2_path) {
        fprintf(stderr, "[FATAL_ERROR]: HOOKRA1N_STAGE2_PATH is not set!\n");
    }
    stage2_shellcode_file = fopen(stage2_path, "ab+");
    assert(stage2_path && "[FATAL_ERROR]: failed to open stage2 file!");
    if(!stage2_path) {
        fprintf(stderr, "[FATAL_ERROR]: failed to open stage2 file!");
    }
    if(stage2_shellcode_file) {
        fseek(stage2_shellcode_file, 0, SEEK_END);
        stage2_shellcode_size = ftell(stage2_shellcode_file);
        fseek(stage2_shellcode_file, 0, SEEK_SET);
        stage2_shellcode = (uint64_t)calloc(1, stage2_shellcode_size);
        assert(stage2_shellcode && "[FATAL_ERROR]: failed to allocate space for stage2 shellcode");
        if(!stage2_shellcode) {
            fprintf(stderr, "[FATAL_ERROR]: failed to open stage2 file!");
        }
        fread((void *)stage2_shellcode, stage2_shellcode_size, 1, stage2_shellcode_file);
    }
}

#endif
