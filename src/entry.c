//
// Created by cryptic on 8/23/22.
//

#include <stdio.h>
#include <utils.h>
#include <hook.h>

__attribute__ ((constructor))
static void checkra1n_hooker_ctor(void) {
    printf("Welcome to hookra1n!\n");
#if __aarch64__
#else
    shellcode_setup();
    int err = setup_hooks();
#endif
}
