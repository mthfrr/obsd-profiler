# cc cat.c

"/usr/bin/cc"\
    -cc1\
    -triple amd64-unknown-openbsd7.1\
    -emit-obj\
    -mrelax-all\
    -disable-free\
    -disable-llvm-verifier\
    -discard-value-names\
    -main-file-name cat.c\
    -mrelocation-model pic\
    -pic-level 1\
    -pic-is-pie\
    -mframe-pointer=all\
    -relaxed-aliasing\
    -fno-rounding-math\
    -mconstructor-aliases\
    -munwind-tables\
    -target-cpu x86-64\
    -target-feature\
    +retpoline-indirect-calls\
    -target-feature\
    +retpoline-indirect-branches\
    -tune-cpu generic\
    -debugger-tuning=gdb\
    -fcoverage-compilation-dir=/home/pol/cat\
    -resource-dir /usr/lib/clang/13.0.0\
    -internal-isystem /usr/lib/clang/13.0.0/include\
    -internal-externc-isystem /usr/include\
    -fdebug-compilation-dir=/home/pol/cat\
    -ferror-limit 19\
    -fwrapv\
    -D_RET_PROTECTOR\
    -ret-protector\
    -fgnuc-version=4.2.1\
    -fno-builtin-malloc\
    -fno-builtin-calloc\
    -fno-builtin-realloc\
    -fno-builtin-valloc\
    -fno-builtin-free\
    -fno-builtin-strdup\
    -fno-builtin-strndup\
    -faddrsig\
    -D__GCC_HAVE_DWARF2_CFI_ASM=1\
    -o cat.o\
    -x c cat.c

"/usr/bin/ld"\
    -e __start\
    --eh-frame-hdr\
    -Bdynamic\
    -dynamic-linker /usr/libexec/ld.so\
    -o a.out\
    /usr/lib/crt0.o\
    /usr/lib/crtbegin.o\
    -L/usr/lib\
    cat.o\
    -lcompiler_rt\
    -lc\
    -lcompiler_rt\
    /usr/lib/crtend.o
