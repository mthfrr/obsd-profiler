CFLAGS=-include namespace.h
LDLAGS=-Wl,-undefined -Wl,dynamic_lookup
SRC=gmon.c mcount.c
OUT=libpatch.so

all:
	$(CC) $(CFLAGS) $(LDLAGS) $(SRC) -o $(OUT)
