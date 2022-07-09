# Compiling and linking options

## Compilation

| cc cat.c           | cc -pg cat.c         |
| ------------------ | -------------------- |
|                    | `-pg`                |
| `-D_RET_PROTECTOR` |                      |
| `-ret_protector`   |                      |
|                    | `-stack-protector 2` |

## Link

| cc cat.c          | cc -pg cat.c       |
| ----------------- | ------------------ |
|                   | `-nopie`           |
| `/usr/lib/crt0.o` | `/usr/lib/gcrt0.o` |
| `-lc`             | `-lc_p`            |

## Tests

|              | Compilation: | Link:    |           |         | Error:                                                            |
| ------------ | ------------ | -------- | --------- | ------- | ----------------------------------------------------------------- |
| cc cat.c     |              |          | `crt0.o`  | `-lc`   |                                                                   |
| cc -pg cat.c | `-pg`        | `-nopie` | `gcrt0.o` | `-lc_p` | `SIGSEGV SIG_DFL code SEGV_MAPERR<1> addr=0x30 trapno=6`          |
|              | `-pg`        |          | `gcrt0.o` | `-lc_p` | `SIGSEGV SIG_DFL code SEGV_ACCERR<2> addr=0x813aff66795 trapno=0` |
