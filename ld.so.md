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

## Link with c vs c_p

| option | result   |
| ------ | -------- |
| -lc    | works    |
| -lc_p  | segfault |

## LD_DEBUG

```
ld.so loading: 'a.out'
exe load offset:  0xda06b12c000
 flags ./a.out = 0x8000000
head ./a.out
obj ./a.out has ./a.out as head
examining: './a.out'
 flags /usr/src/libexec/ld.so/ld.so = 0x0
obj /usr/src/libexec/ld.so/ld.so has ./a.out as head
static tls size=0 align=8 offset=0
	Start            End              Type  Open Ref GrpRef Name
	00000da06b12c000 00000da06b154000 exe   1    0   0      ./a.out
	00000da311b54000 00000da311b54000 ld.so 0    1   0      /usr/src/libexec/ld.so/ld.so
dynamic loading done, success.
tib new=0xda28803a940
doing preinitarray obj 0xda323f57800 @0xda06b14c220: [./a.out]
version 0 callbacks requested
Segmentation fault (core dumped)

```

## run debugger

`egdb -ex=starti -ex='b _dl_call_preinit' --args env LD_DEBUG= ./a.out`

## Calls

- \_dl_call_preinit
  - \_libc_preinit
    - issetugid()

## call issetugid()

Register status:

```
rax 0x1fbe1817000 2181331775488
rbx 0xc 12
rcx 0x1fb8b0374ab 2179880678571
rdx 0x1e 30
rsi 0x1fb8b239020 2179882782752
rdi 0x2 2
rbp 0x7f7ffffdc900 0x7f7ffffdc900
rsp 0x7f7ffffdc8c8 0x7f7ffffdc8c8
r8 0x1fb7d6c2c00 2179652660224
r9 0x1fb8b037240 2179880677952
r10 0x1fb8b23903d 2179882782781
r11 0xf2f8b48300fd711a -938802047556423398
r12 0x1f97606cbdf 2170938641375
r13 0x1f97606a040 2170938630208
r14 0x1f97607a940 2170938698048
r15 0x7f7ffffdcb98 140187732396952
rip 0x1f976086790 0x1f976086790 <issetugid>
eflags 0x346 [ PF ZF TF IF ]
cs 0x2b 43
ss 0x23 35
ds 0x23 35
es 0x23 35
fs 0x23 35
gs 0x23 35

```

Code

```
push %rbp ={12}
lea (%rsp),%rbp
callq <__mcount>
pop %rbp
mov $0xfd,%eax
mov %rcx,%r10
syscall
retq
int3
int3
int3...
```

## issetugid > \_\_mcount

[source](https://github.com/openbsd/src/blob/master/sys/arch/amd64/include/profile.h)

Code

```
0x1f9760733a0 <__mcount>        push   %rbp                                                                                                                                                  0x1f9760733a1 <__mcount+1>      mov    %rsp,%rbp
0x1f9760733a4 <__mcount+4>      sub    $0x38,%rsp
0x1f9760733a8 <__mcount+8>      mov    %rdi,(%rsp)
0x1f9760733ac <__mcount+12>     mov    %rsi,0x8(%rsp)
0x1f9760733b1 <__mcount+17>     mov    %rdx,0x10(%rsp)
0x1f9760733b6 <__mcount+22>     mov    %rcx,0x18(%rsp)
0x1f9760733bb <__mcount+27>     mov    %r8,0x20(%rsp)
0x1f9760733c0 <__mcount+32>     mov    %r9,0x28(%rsp)
0x1f9760733c5 <__mcount+37>     mov    %rax,0x30(%rsp)
0x1f9760733ca <__mcount+42>     mov    0x0(%rbp),%r11
0x1f9760733ce <__mcount+46>     mov    0x8(%r11),%rdi
0x1f9760733d2 <__mcount+50>     mov    0x8(%rbp),%rsi
0x1f9760733d6 <__mcount+54>     callq  0x1f976073410 <_mcount>
0x1f9760733db <__mcount+59>     mov    (%rsp),%rdi
0x1f9760733df <__mcount+63>     mov    0x8(%rsp),%rsi
0x1f9760733e4 <__mcount+68>     mov    0x10(%rsp),%rdx
0x1f9760733e9 <__mcount+73>     mov    0x18(%rsp),%rcx
0x1f9760733ee <__mcount+78>     mov    0x20(%rsp),%r8
0x1f9760733f3 <__mcount+83>     mov    0x28(%rsp),%r9
0x1f9760733f8 <__mcount+88>     mov    0x30(%rsp),%rax
0x1f9760733fd <__mcount+93>     leaveq
0x1f9760733fe <__mcount+94>     retq
0x1f9760733ff <__mcount+95>     lfence
0x1f976073402                       int3
0x1f976073403                       int3
```

### ??? segfault on syscall instruction

`issetugid+19: syscall`

regs before:

```
rax            0xfd                253
rbx            0xc                 12
rcx            0xf22ac2a54ab       16641591760043
rdx            0x1e                30
rsi            0xf22ac4a7020       16641593864224
rdi            0x2                 2
rbp            0x7f7ffffcb190      0x7f7ffffcb190
rsp            0x7f7ffffcb158      0x7f7ffffcb158
r8             0xf227a728000       16640757628928
r9             0xf22ac2a5240       16641591759424
r10            0xf22ac2a54ab       16641591760043
r11            0x8fb075122df747bb  -8092839809443739717
r12            0xf2046fb8bdf       16631304260575
r13            0xf2046fb6040       16631304249408
r14            0xf2046fc6940       16631304317248
r15            0x7f7ffffcb428      140187732325416
rip            0xf2046fd27a3       0xf2046fd27a3 <issetugid+19>
eflags         0x346               [ PF ZF TF IF ]
cs             0x2b                43
ss             0x23                35
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
```

after:

```
rax            0x1                 1
rbx            0xc                 12
rcx            0xf2046fd27a5       16631304365989
rdx            0x1e                30
rsi            0xf22ac4a7020       16641593864224
rdi            0x2                 2
rbp            0x7f7ffffcb190      0x7f7ffffcb190
rsp            0x7f7ffffcb158      0x7f7ffffcb158
r8             0xf227a728000       16640757628928
r9             0xf22ac2a5240       16641591759424
r10            0xf22ac2a54ab       16641591760043
r11            0x346               838
r12            0xf2046fb8bdf       16631304260575
r13            0xf2046fb6040       16631304249408
r14            0xf2046fc6940       16631304317248
r15            0x7f7ffffcb428      140187732325416
rip            0xf2046fd27a5       0xf2046fd27a5 <issetugid+21>
eflags         0x347               [ CF PF ZF TF IF ]
cs             0x2b                43
ss             0x23                35
ds             0x23                35
es             0x23                35
fs             0x23                35
gs             0x23                35
```

changes:

```
rax            0xfd                253
rax            0x1                 1

rcx            0xf22ac2a54ab       16641591760043
rcx            0xf2046fd27a5       16631304365989

r11            0x8fb075122df747bb  -8092839809443739717
r11            0x346               838

eflags         0x346               [    PF ZF TF IF ]
eflags         0x347               [ CF PF ZF TF IF ]

```

## kernel

sys/arch/amd64/amd64/trap.c:syscall:518

since CF is set: we went through `bad:`
which mean copyin() return an error.
which is 1 since rax is equal to 1

# EXPLICATION

There is a kernel check when doing syscall asserting
that PC is in read-on memory or in permitted text:
`un-writeable permitted text (sigtramp, libc, ld.so)`

[zepourquoi](https://marc.info/?l=openbsd-tech&m=157488907117170)

```
For static binaries, the valid regions are the base program's text
segment and the signal trampoline page.

For dynamic binaries, valid regions are ld.so's text segment, the signal
trampoline, and libc.so's text segment... AND the main program's text.
```

## static to shared

`cc -shared -o libc_p.so -Wl,--whole-archive -lc_p`

## procmap ?

> procmap has benen updated to show the syscall regions with 'e' and the
> stack regions with 'S'.

`$rip=0x3ea66949790` -> third map : r-x--p- !missing e

```
pol@obsd /home/pol/cat $ doas procmap -a 60001
Start            End                 Size  Offset           rwxSepc  RWX  I/W/A Dev     Inode - File
0000000000001000-0000000000001000       0k 0000000000000000 -----s- (---) 0/0/0 00:00       0 -   [ anon ]
000003ea6692d000-000003ea66932fff      24k 0000000000000000 r----p- (rwx) 1/0/0 00:10  699902 - /home/pol/cat/a.out [0xfffffd812646a318]
000003ea66933000-000003ea6694cfff     104k 0000000000005000 r-x--p- (rwx) 1/0/0 00:10  699902 - /home/pol/cat/a.out [0xfffffd812646a318]
000003ea6694d000-000003ea6694dfff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ea6694e000-000003ea6694efff       4k 000000000001e000 rw---p- (rwx) 1/0/0 00:10  699902 - /home/pol/cat/a.out [0xfffffd812646a318]
000003ea6694f000-000003ea6694ffff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ea66950000-000003ea66954fff      20k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ec6694d000-000003ec6694d000       0k 0000000000000000 -----s- (---) 0/0/0 00:00       0 -   [ anon ]
000003ec68efd000-000003ec68efdfff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ec70669000-000003ec70669fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ec76d45000-000003ec76d45fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ec8c641000-000003ec8c641fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ec931d4000-000003ec931d4fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ecad368000-000003ecad368fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ecaf0ab000-000003ecaf0abfff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ecd3fd6000-000003ecd3fd6fff       4k 0000000000000000 r-x-ep+ (rwx) 1/0/1 00:00       0 -   [ uvm_aobj ]
000003ecdbbf6000-000003ecdbbf6fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003eced182000-000003eced182fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ecf8361000-000003ecf8361fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed050a8000-000003ed050a8fff       4k 0000000000000000 r----s- (r--) 1/0/1 00:00       0 -   [ uvm_aobj ]
000003ed0bae9000-000003ed0bae9fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed10314000-000003ed10316fff      12k 0000000000000000 r----p+ (rwx) 1/0/0 00:08  151222 - /usr/src/libexec/ld.so/ld.so [0xfffffd811a8a2b08]
000003ed10416000-000003ed10423fff      56k 0000000000002000 r-x-ep- (rwx) 1/0/0 00:08  151222 - /usr/src/libexec/ld.so/ld.so [0xfffffd811a8a2b08]
000003ed10514000-000003ed10514fff       4k 0000000000010000 r----p- (rwx) 1/0/0 00:08  151222 - /usr/src/libexec/ld.so/ld.so [0xfffffd811a8a2b08]
000003ed10515000-000003ed10515fff       4k 0000000000011000 rw---p- (rwx) 1/0/0 00:08  151222 - /usr/src/libexec/ld.so/ld.so [0xfffffd811a8a2b08]
000003ed10516000-000003ed10516fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed12cba000-000003ed12cbafff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed19c8a000-000003ed19c8afff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed1a1a9000-000003ed1a1a9fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed2f873000-000003ed2f873fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed31092000-000003ed31092fff       4k 0000000000000000 -----p+ (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed31093000-000003ed31094fff       8k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed31095000-000003ed31095fff       4k 0000000000000000 -----p+ (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed4b2fd000-000003ed4b2fdfff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
000003ed4c9b9000-000003ed4c9b9fff       4k 0000000000000000 rw---p- (rwx) 1/0/0 00:00       0 -   [ anon ]
00007f7ffded6000-00007f7fffbd5fff   29696k 0000000000000000 -----p+ (rwx) 1/0/0 00:00       0 -   [ stack ]
00007f7fffbd6000-00007f7ffffd5fff    4096k 0000000000000000 rw-S-p- (rwx) 1/0/0 00:00       0 -   [ anon ]
 total                               4420k
```
