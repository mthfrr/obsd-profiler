# Download sources

## DL and compile libc

```sh
cd /usr/src/
wget https://ftp.fr.openbsd.org/pub/OpenBSD/7.1/src.tar.gz
tar -zxf src.tar.gz

cd lib/libc
make -j4
```

## Compile with libc static

```sh
cc -pg -c cat.c
ld -e __start --eh-frame-hdr -Bstatic -nopie -o a.out /usr/lib/gcrt0.o /usr/lib/crtbegin.o /usr/src/lib/libc/libc_p.a cat.o -L/usr/lib -lcompiler_rt /usr/lib/crtend.o
```
