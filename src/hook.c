//
// Created by cryptic on 8/23/22.
//

#include <mach-o/dyld.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <hook.h>
#include <substitute.h>

#if __aarch64__
#else

size_t stage2_shellcode_size;
FILE *stage2_shellcode_file;
uint64_t stage2_shellcode;

int setup_hooks(void) {
    slide = (uint64_t)_dyld_get_image_vmaddr_slide(0);
    t8015_stage2_address = (uint64_t)(slide + 0x100012daa);
    uint64_t version = (uint64_t)(slide + 0x100027174);
    bool match = strcmp((const char *)version, "Checkra1n 0.1337.1\n");
    assert(match && "[FATAL_ERROR]: Unsupported checkra1n version!");
    if(!match) {
        fprintf(stderr, "[FATAL_ERROR]: Unsupported checkra1n version!\n");
        exit(-1);
    }
    memcpy_address = (uint64_t)(slide + 0x10001cd82);
    struct substitute_function_hook code_hooks[] = {
            {
                    (void *)t8015_stage2_address,
                    &t8015_stage2_hook_tramp,
                    t8015_stage2_jumpback_address,
                    0,
            },
    };
    t8015_stage2_jumpback_address = (void *)(slide + 0x100012e25);
    int ret = substitute_hook_functions(code_hooks, sizeof(code_hooks) / sizeof(*code_hooks), NULL, 0);

    return ret;
}

__attribute__((naked))
__attribute__ ((noinline))
static void t8015_stage2_hook_tramp(void) {
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
    __asm__ volatile("jmp *%0": : "r" (t8015_stage2_jumpback_address));
}

#endif
