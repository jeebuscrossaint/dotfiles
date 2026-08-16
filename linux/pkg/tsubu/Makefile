.POSIX:

PKG_CONFIG = pkg-config

PKGS = wayland-client wayland-cursor fcft pixman-1
INCS != $(PKG_CONFIG) --cflags $(PKGS)
LIBS != $(PKG_CONFIG) --libs $(PKGS)

CPPFLAGS = -D_GNU_SOURCE
COAT_INCS = -I$(HOME)/.config/tsubu
CFLAGS   = -pedantic -Wall -Wno-unused-function -Wno-strict-prototypes $(COAT_INCS) $(INCS)
LDLIBS   = $(LIBS)

all: tsubu

config.h: config.def.h
	cp $< $@

tsubu: xdg-shell-protocol.o wlr-layer-shell-unstable-v1-protocol.o
tsubu.o: config.h xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h

WAYLAND_PROTOCOLS != $(PKG_CONFIG) --variable=pkgdatadir wayland-protocols
WAYLAND_SCANNER   != $(PKG_CONFIG) --variable=wayland_scanner wayland-scanner

xdg-shell-protocol.c xdg-shell-protocol.h: \
	$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml
wlr-layer-shell-unstable-v1-protocol.c wlr-layer-shell-unstable-v1-protocol.h: \
	wlr-layer-shell-unstable-v1.xml

%-protocol.c:
	$(WAYLAND_SCANNER) private-code $< $@
%-protocol.h:
	$(WAYLAND_SCANNER) client-header $< $@

run: tsubu
	WAYLAND_DEBUG=1 ./tsubu -d 0 "█"

clean:
	rm -f tsubu *.o *-protocol.*

.PHONY: all clean
