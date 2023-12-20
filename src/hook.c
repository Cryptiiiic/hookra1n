//
// Created by cryptic on 8/23/22.
//

#include <mach-o/dyld.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <hook.h>
#include <stdlib.h>

#if __aarch64__
#include <substitute.h>
int setup_hooks(void) {
    slide = (uint64_t)_dyld_get_image_vmaddr_slide(0);
    t8015_stage2_address = (uint64_t)(slide + 0);
    uint64_t version = (uint64_t)(slide + 0);
    bool match = strcmp((const char *)version, "Checkra1n 0.1337.1\n");
    assert(match && "[FATAL_ERROR]: Unsupported checkra1n version!");
    if(!match) {
        fprintf(stderr, "[FATAL_ERROR]: Unsupported checkra1n version!\n");
        exit(-1);
    }
    memcpy_address = (uint64_t)(slide + 0);
    struct substitute_function_hook code_hooks[] = {
            {
                    (void *)t8015_stage2_address,
                    &stage2_hook_tramp,
                    stage2_jumpback_address,
                    0,
            },
    };
    stage2_jumpback_address = (void *)(slide + 0);
    int ret = substitute_hook_functions(code_hooks, sizeof(code_hooks) / sizeof(*code_hooks), NULL, 0);

    return ret;
}

__attribute__((naked))
__attribute__ ((noinline))
static void stage2_hook_tramp(void) {
    //
}
#else
#include <rd_route.h>
#include <mach/mach_error.h>

size_t stage2_shellcode_size;
FILE *stage2_shellcode_file;
uint64_t stage2_shellcode;

int setup_hooks(void) {
    int image_index = -1;
    for(int i = 0; i < _dyld_image_count(); i++) {
        if(strstr(_dyld_get_image_name(i), "checkra1n")) {
            image_index = i;
            break;
        }
    }
    if(image_index == -1) {
        return 0;
    }
    slide = (uint64_t)_dyld_get_image_vmaddr_slide(0);
    // 0.1337.1 t8015_stage2_address = (uint64_t)(slide + 0x100012daa);
    // 0.1337.1 uint64_t version = (uint64_t)(slide + 0x100027174);
    t8015_stage2_address = (uint64_t)(slide + 0x100012c7a); // 0.1337.2
    t8010_stage2_address = (uint64_t)(slide + 0x100012c45); // 0.1337.2
    uint64_t version = (uint64_t)(slide + 0x100027174); // 0.1337.2
    bool match = strcmp((const char *)version, "Checkra1n 0.1337.2\n");
    assert(match && "[FATAL_ERROR]: Unsupported checkra1n version!");
    if(!match) {
        fprintf(stderr, "[FATAL_ERROR]: Unsupported checkra1n version!\n");
        exit(-1);
    }
    // 0.1337.1  memcpy_address = (uint64_t)(slide + 0x10001cd82);
    memcpy_address = (uint64_t)(slide + 0x10001cc62); // 0.1337.2
    kern_return_t kr = rd_route((void *)t8015_stage2_address, &stage2_hook_tramp, stage2_jumpback_address);
    assert(!kr && "[FATAL_ERROR]: rd_route: t8015_stage2 hook failed!" && mach_error_string(kr));
    if(kr) {
        fprintf(stderr, "[FATAL_ERROR]: rd_route: t8015_stage2 hook failed! (%s)\n", mach_error_string(kr));
        exit(-1);
    }
    kr = rd_route((void *)t8010_stage2_address, &stage2_hook_tramp, stage2_jumpback_address);
    assert(!kr && "[FATAL_ERROR]: rd_route: t8010_stage2 hook failed!" && mach_error_string(kr));
    if(kr) {
        fprintf(stderr, "[FATAL_ERROR]: rd_route: t8010_stage2 hook failed! (%s)\n", mach_error_string(kr));
        exit(-1);
    }
    // 0.1337.1 stage2_jumpback_address = (void *)(slide + 0x100012e25);
    stage2_jumpback_address = (void *)(slide + 0x100012cf5); // 0.1337.2
    return 0;
}

__attribute__((naked))
__attribute__ ((noinline))
static void stage2_hook_tramp(void) {
    __asm__ volatile("mov %rax, %r9");
    __asm__ volatile("mov %rdi, %r10");
    __asm__ volatile("mov %rcx, %r11");
    __asm__ volatile(
            ".intel_syntax noprefix     \n"
            "mov     rdx, %V[reg]      \n"
            ".att_syntax                \n"
            :
            : [reg] "r" (stage2_shellcode_size)
    : "edx"
    );
    __asm__ volatile("mov %rdx, %r12");
    __asm__ volatile(
            ".intel_syntax noprefix     \n"
            "mov     rsi, %V[reg2]      \n"
            ".att_syntax                \n"
            :
            : [reg2] "r" (stage2_shellcode)
    : "rsi"
    );
    __asm__ volatile(
            ".intel_syntax noprefix     \n"
            "mov     r8, %V[reg3]      \n"
            ".att_syntax                \n"
            :
            : [reg3] "r" (memcpy_address)
    : "r8"
    );
    __asm__ volatile("mov %r9, %rax");
    __asm__ volatile("mov %r10, %rdi");
    __asm__ volatile("mov %r11, %rcx");
    __asm__ volatile("call *%r8");
    __asm__ volatile("mov %r12d, %r15d");
    __asm__ volatile("jmp *%0": : "r" (stage2_jumpback_address));
}

#endif
