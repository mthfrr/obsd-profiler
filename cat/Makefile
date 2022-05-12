CC=gcc
CPPFLAGS=
CFLAGS=-Wall -Werror -Wexta -pedantic -g
LDFLAGS=

BIN=cat

profile: CFLAGS= -pg
profile: $(BIN)

$(BIN): cat.c

clean:
	$(RM) $(BIN)
