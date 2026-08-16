# ww — Universal Wayland Wallpaper Setter
# Plain make, so it builds with the rest of pkg/ without xmake.

PREFIX ?= $(HOME)/.local

PKGS = wayland-client libwebp libtiff-4 libjxl libavcodec libavformat libavutil libswscale
INCS != pkg-config --cflags $(PKGS)
LIBS != pkg-config --libs $(PKGS)

CXXFLAGS ?= -O2 -std=c++20 -Wall
ALLFLAGS  = $(CXXFLAGS) -Iinc -Ibuild/protocols $(INCS)

SRC   = $(wildcard src/*.cc)
PROTO = build/protocols/xdg-shell-protocol.c build/protocols/wlr-layer-shell-unstable-v1-protocol.c
OBJ   = $(SRC:.cc=.o) $(PROTO:.c=.o)

all: ww

build/protocols/xdg-shell-client-protocol.h:
	./generate_protocols.sh

$(OBJ): build/protocols/xdg-shell-client-protocol.h

%.o: %.cc
	$(CXX) $(ALLFLAGS) -c $< -o $@

%.o: %.c
	$(CC) -O2 -Ibuild/protocols -c $< -o $@

ww: $(OBJ)
	$(CXX) $(OBJ) $(LIBS) -lm -o $@

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f ww $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f ww $(OBJ)
	rm -rf build

.PHONY: all install clean
