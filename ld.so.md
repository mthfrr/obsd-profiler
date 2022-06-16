cat.c compilation commands

# This segfaults

`cc -v -pg -g cat.c`

# Link command

```
ld -e __start --eh-frame-hdr -Bdynamic -dynamic-linker /usr/libexec/ld.so -nopie -o a.out /usr/lib/gcrt0.o /usr/lib/crtbegin.o -L/usr/lib cat.o -lcompiler_rt -lc_p -lcompiler_rt /usr/lib/crtend.o
```

# Tests

| Options          | Output              |
| ---------------- | ------------------- |
| -nopie gcrt0 -lc | `Works`             |
| -nopie crt0 -lc  | `Works no gmon.out` |
| gcrt0 -lc        | `Works`             |

## With my libc

`ld -e __start --eh-frame-hdr -Bdynamic -dynamic-linker /usr/libexec/ld.so -o a.out /usr/lib/gcrt0.o /usr/lib/crtbegin.o -L/usr/src/lib/libc cat.o -lc_p -L/usr/lib -lcompiler_rt /usr/lib/crtend.o`
`--verbose`

gdb9:

```
(gdb) info stack
#0  issetugid () at /tmp/-:3
#1  0x000003c5db8a7b8c in _libc_preinit (argc=<optimized out>, argv=<optimized out>, envp=<optimized out>, cb=0x3c825486590 <_dl_cb_cb>) at dlfcn/init.c:117
#2  0x000003c82547cc18 in _dl_call_preinit (object=0x3c8a6119000) at /usr/src/libexec/ld.so/loader.c:767
#3  _dl_boot (argv=<optimized out>, envp=<optimized out>, dyn_loff=<optimized out>, dl_data=0x7f7ffffe6410) at /usr/src/libexec/ld.so/loader.c:696
#4  0x000003c82547b956 in _dl_start () at /usr/src/libexec/ld.so/amd64/ldasm.S:61
#5  0x0000000000000000 in ?? ()
(gdb) info line
Line 3 of "/tmp/-" starts at address 0x3c5db8bc780 <issetugid> and ends at 0x3c5db8bc781 <issetugid+1>.
(gdb) info sharedlibrary
From                To                  Syms Read   Shared Object Library
0x000003c82547d000  0x000003c825487c41  Yes         /usr/libexec/ld.so
```

## with debug ld.so

`ld -e __start --eh-frame-hdr -Bdynamic -dynamic-linker /usr/src/libexec/ld.so/ld.so -o a.out /usr/lib/gcrt0.o /usr/lib/crtbegin.o -L/usr/src/lib/libc cat.o -lc_p -L/usr/lib -lcompiler_rt /usr/lib/crtend.o`