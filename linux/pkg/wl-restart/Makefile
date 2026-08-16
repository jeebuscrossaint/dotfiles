# wl-restart — plain make, so it builds with the rest of pkg/ without cmake.
# The sources are pure libc, no pkg-config needed.

PREFIX ?= $(HOME)/.local

CFLAGS ?= -O2 -Wall -Wextra

SRC = $(wildcard src/*.c)
OBJ = $(SRC:.c=.o)

all: wl-restart

wl-restart: $(OBJ)
	$(CC) $(OBJ) -o $@

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f wl-restart $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f wl-restart $(OBJ)

.PHONY: all install clean
