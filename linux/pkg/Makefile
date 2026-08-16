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

SUBDIRS = dwl mew slstatus

# Packages each tree needs. wlroots is version-pinned: dwl 0.8 builds against
# 0.19 specifically, and Artix ships 0.18/0.19/0.20 as coexisting packages, so
# having 0.20 installed for sway does NOT satisfy dwl.
PKGDEPS = wlroots0.19 wayland wayland-protocols libinput libxkbcommon pixman fcft tllist

all: $(SUBDIRS)

$(SUBDIRS):
	@echo "==> building $@"
	@$(MAKE) --no-print-directory -C $@

install: all
	@for d in $(SUBDIRS); do \
		echo "==> installing $$d into $(PREFIX)"; \
		$(MAKE) --no-print-directory -C $$d install \
			PREFIX="$(PREFIX)" MANPREFIX="$(MANPREFIX)" || exit 1; \
	done
	@echo
	@echo "installed. start the session from a TTY with:  dwl-run"

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

.PHONY: all install clean deps $(SUBDIRS)
