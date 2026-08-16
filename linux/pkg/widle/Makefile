.POSIX:

VERSION = 1.0

PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

PKG_CONFIG = pkg-config

PKGS = wayland-client
INCS != $(PKG_CONFIG) --cflags $(PKGS)
LIBS != $(PKG_CONFIG) --libs $(PKGS)

WICPPFLAGS = -DVERSION=\"$(VERSION)\"
WICFLAGS   = -std=c99 -pedantic -Wall -Wno-strict-prototypes $(INCS) $(WICPPFLAGS) $(CPPFLAGS) $(CFLAGS)
LDLIBS     = $(LIBS)

all: widle

.c.o:
	$(CC) -o $@ $(WICFLAGS) -c $<

widle.o: ext-idle-notify-v1-protocol.h
widle: widle.o ext-idle-notify-v1-protocol.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

WAYLAND_SCANNER   != $(PKG_CONFIG) --variable=wayland_scanner wayland-scanner
WAYLAND_PROTOCOLS != $(PKG_CONFIG) --variable=pkgdatadir wayland-protocols

ext-idle-notify-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		$(WAYLAND_PROTOCOLS)/staging/ext-idle-notify/ext-idle-notify-v1.xml $@
ext-idle-notify-v1-protocol.h:
	$(WAYLAND_SCANNER) client-header \
		$(WAYLAND_PROTOCOLS)/staging/ext-idle-notify/ext-idle-notify-v1.xml $@

clean:
	rm -f widle widle.o ext-idle-notify-v1-protocol.[cho]

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f widle $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/widle
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f widle.1 $(DESTDIR)$(MANPREFIX)/man1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/widle.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/widle
	rm -f $(DESTDIR)$(MANPREFIX)/man1/widle.1

.PHONY: all clean install uninstall
