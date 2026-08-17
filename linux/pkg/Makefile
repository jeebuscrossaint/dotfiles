# pkg — the compile-time-configured half of the desktop.
#
# These are vendored source trees, not packages. They are configured by editing
# C headers and recompiling, so the source has to live here rather than being
# installed from a repo. `config.def.h` in each tree is the real configuration;
# `config.h` is generated from it by each tree's own Makefile and is not tracked.
#
#   make            build everything
#   make install    build + install into ~/.local (no root needed)
#   make clean      remove build artefacts and generated config.h
#   make deps       check that the build dependencies are present
#
# PREFIX defaults to ~/.local so nothing needs sudo and everything lands on the
# PATH already used by ~/.local/bin scripts.

PREFIX    ?= $(HOME)/.local
MANPREFIX ?= $(PREFIX)/share/man

SUBDIRS = dwl slstatus tsubu widle wlock ww wl-restart

# Packages each tree needs. wlroots is version-pinned: dwl 0.8 builds against
# 0.19 specifically, and Artix ships 0.18/0.19/0.20 as coexisting packages, so
# having 0.20 installed for sway does NOT satisfy dwl.
PKGDEPS = wlroots0.19 wayland wayland-protocols libinput libxkbcommon pixman fcft tllist \
          libwebp libtiff libjxl ffmpeg

all: $(SUBDIRS)

$(SUBDIRS):
	@echo "==> building $@"
	@$(MAKE) --no-print-directory -C $@

install: all
	@for d in $(SUBDIRS); do \
		if $(MAKE) -nC $$d install >/dev/null 2>&1; then \
			echo "==> installing $$d into $(PREFIX)"; \
			$(MAKE) --no-print-directory -C $$d install \
				PREFIX="$(PREFIX)" MANPREFIX="$(MANPREFIX)" >/dev/null || exit 1; \
		else \
			echo "==> installing $$d into $(PREFIX) (no install target, copying)"; \
			mkdir -p "$(PREFIX)/bin" && cp -f "$$d/$$d" "$(PREFIX)/bin/" || exit 1; \
		fi; \
	done
	@echo
	@echo "installed. start the session from a TTY with:  dwl-run"
	@echo
	@echo "NOTE: wlock reads /etc/shadow, so it needs to be setuid root. Installed"
	@echo "into $(PREFIX) it is owned by you and will refuse to lock, exiting with"
	@echo "'getspnam failed'. It fails BEFORE engaging the lock, so it cannot lock"
	@echo "you out -- but to actually use it run:"
	@echo "    make install-wlock-suid      (this one does need root)"

# wlock verifies passwords against /etc/shadow, which only root can read. This
# is the one thing in this tree that cannot live in ~/.local.
install-wlock-suid: wlock
	sudo install -o root -g root -m 4755 wlock/wlock /usr/local/bin/wlock
	@echo "wlock installed setuid root at /usr/local/bin/wlock"

clean:
	@for d in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$d clean 2>/dev/null || true; done
	@rm -f $(SUBDIRS:=/config.h)

# Non-fatal: report what is missing rather than failing, since names differ
# across distributions.
deps:
	@missing=""; \
	for p in $(PKGDEPS); do \
		pacman -Q "$$p" >/dev/null 2>&1 || missing="$$missing $$p"; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "missing (pacman names):$$missing"; \
		echo "install with: sudo pacman -S --needed$$missing"; \
	else \
		echo "all build dependencies present"; \
	fi

.PHONY: all install install-wlock-suid clean deps $(SUBDIRS)
