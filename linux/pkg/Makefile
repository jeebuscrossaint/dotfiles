# pkg — the compile-time-configured half of the desktop.
#
# One tree left. dwl, wlock, widle, tsubu, wl-restart and ww were all removed
# once mango replaced dwl: mango is packaged on both Arch and OpenBSD, and the
# rest were either unused (wlock, widle, tsubu) or only existed to prop dwl up
# (wl-restart). slstatus stays because it feeds waybar's status module and is one
# of the few status generators that builds on OpenBSD as well as Linux.
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

SUBDIRS = slstatus

# What slstatus needs. The wlroots/wayland/fcft pile that used to be here went
# with dwl -- the compositor is mango now, installed from the AUR on Arch and
# ports on OpenBSD, so its dependencies are the package manager's problem rather
# than this tree's.
PKGDEPS = ncurses

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
	@echo "installed. start the session from a TTY with:  mango-run"

clean:
	@for d in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$d clean 2>/dev/null || true; done
	@rm -f $(SUBDIRS:=/config.h)

# Non-fatal: report what is missing rather than failing, since names differ
# across distributions -- and this tree is expected to build on OpenBSD too,
# where pacman does not exist at all.
deps:
	@command -v pacman >/dev/null 2>&1 || { \
		echo "not an Arch-family system; check for: $(PKGDEPS)"; exit 0; }
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
