LDLAGS=-Wl,-undefined -Wl,dynamic_lookup
SRC=gmon.c mcount.c
OUT=libpatch.so

all:
	$(CC) $(LDLAGS) $(SRC) -o $(OUT)
