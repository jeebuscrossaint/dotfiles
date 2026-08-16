/* See LICENSE file for copyright and license details. */
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <poll.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/signalfd.h>
#include <sys/wait.h>
#include <unistd.h>
#include <wayland-client.h>

#include "ext-idle-notify-v1-protocol.h"

static struct wl_display *display;
static struct wl_registry *registry;
static struct wl_seat *seat;
static struct ext_idle_notifier_v1 *idle_notifier;
static struct ext_idle_notification_v1 *idle_notif;

static char **cmd;
static int signal_fd = -1;
static int timeout = 360;
static pid_t cmdpid;

static bool background = false; /* -b option */
static bool restart = true; /* -r option */

static void
noop()
{
	/*
	 * :3c
	 */
}

static void
die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	if (fmt[0] && fmt[strlen(fmt)-1] == ':') {
		fputc(' ', stderr);
		perror(NULL);
	} else {
		fputc('\n', stderr);
	}

	exit(EXIT_FAILURE);
}

static void
cmdexec()
{
	if (!cmd)
		exit(0);
	if (cmdpid && !background)
		return;
	switch (cmdpid = fork()) {
	case -1:
		die("fork:");
	case 0:
		execvp(cmd[0], cmd);
		die("execvp:");
	}
}

static void
idle_notif_handled_idled(void *data, struct ext_idle_notification_v1 *notif)
{
	cmdexec();
}

static const struct ext_idle_notification_v1_listener idle_notif_listener = {
	.idled = idle_notif_handled_idled,
	.resumed = noop,
};

static void
retimeout(void)
{
	if (idle_notif)
		ext_idle_notification_v1_destroy(idle_notif);
	idle_notif = ext_idle_notifier_v1_get_idle_notification(
		idle_notifier, timeout * 1000, seat);
	ext_idle_notification_v1_add_listener(idle_notif, &idle_notif_listener, NULL);
}

static void
registry_global(void *data, struct wl_registry *wl_registry,
		uint32_t name, const char *interface, uint32_t version)
{
	if (!strcmp(interface, ext_idle_notifier_v1_interface.name))
		idle_notifier = wl_registry_bind(
			registry, name, &ext_idle_notifier_v1_interface, 1);
	else if (!strcmp(interface, wl_seat_interface.name))
		seat = wl_registry_bind(registry, name, &wl_seat_interface, 2);
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_global,
	.global_remove = noop,
};

static void
setup(void)
{
	sigset_t mask;

	if (!(display = wl_display_connect(NULL)))
		die("failed to connect to wayland display");

	registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);

	if (!idle_notifier)
		die("compositor lacks ext_idle_notifier_v1 protocol");

	sigemptyset(&mask);
	sigaddset(&mask, SIGUSR1); /* idle notification */
	sigaddset(&mask, SIGCHLD);

	if (sigprocmask(SIG_BLOCK, &mask, NULL) < 0)
		die("sigprocmask:");

	if ((signal_fd = signalfd(-1, &mask, SFD_NONBLOCK)) < 0)
		die("signalfd:");

	retimeout();
}

static void
run(void)
{
	ssize_t n;
	int wstat;
	struct signalfd_siginfo si;
	struct pollfd pfds[] = {
		{ .fd = wl_display_get_fd(display), .events = POLLIN },
		{ .fd = signal_fd,                  .events = POLLIN },
	};

	for (;;) {
		if (wl_display_prepare_read(display) < 0)
			if (wl_display_dispatch_pending(display) < 0)
				die("wl_display_dispatch_pending:");

		if (wl_display_flush(display) < 0)
			die("wl_display_flush:");

		if (poll(pfds, 2, -1) < 0) {
			wl_display_cancel_read(display);
			die("poll:");
		}

		if (pfds[1].revents & POLLIN) {
			n = read(signal_fd, &si, sizeof(si));
			if (n != sizeof(si))
				die("signalfd/read:");

			switch (si.ssi_signo) {
			case SIGUSR1:
				cmdexec();
				if (restart)
					retimeout();
				break;
			case SIGCHLD:
				if (waitpid(si.ssi_pid, &wstat, WNOHANG) < 0)
					die("waitpid:");
				if (WIFEXITED(wstat) && WEXITSTATUS(wstat))
					fprintf(stderr, "command exited with status %d\n", WEXITSTATUS(wstat));
				else if (WIFSIGNALED(wstat))
					fprintf(stderr, "command terminated due to signal %d\n", WTERMSIG(wstat));
				cmdpid = 0;
				break;
			}
		}

		if (!(pfds[0].revents & POLLIN)) {
			wl_display_cancel_read(display);
			continue;
		}

		if (wl_display_read_events(display) < 0)
			break;

		if (wl_display_dispatch_pending(display) < 0)
			die("wl_display_dispatch_pending:");
	}
}

int
main(int argc, char *argv[])
{
	int opt;

	while ((opt = getopt(argc, argv, "bct:s:hv")) != -1)  {
		switch (opt) {
		case 'b':
			background = true;
			break;
		case 'c':
			restart = false;
			break;
		case 't':
			timeout = atoi(optarg);
			break;
		case 'v':
			puts("widle " VERSION);
			return EXIT_SUCCESS;
		case 'h':
		default:
			fprintf(stderr, "usage: %s [-bcv] [-t timeout] [cmd [arg ...]]\n", argv[0]);
			return opt == 'h' ? EXIT_SUCCESS : EXIT_FAILURE;
		}
	}
	if (argc - optind > 0)
		cmd = argv + optind;

	setup();
	run();
	ext_idle_notification_v1_destroy(idle_notif);
	ext_idle_notifier_v1_destroy(idle_notifier);
	wl_seat_destroy(seat);
	wl_registry_destroy(registry);
	wl_display_disconnect(display);

	return EXIT_SUCCESS;
}
