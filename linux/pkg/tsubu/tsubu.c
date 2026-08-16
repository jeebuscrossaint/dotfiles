/* See LICENSE file for copyright and license details. */
#include <ctype.h>
#include <errno.h>
#include <linux/input-event-codes.h>
#include <locale.h>
#include <poll.h>
#include <semaphore.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/signalfd.h>
#include <sys/timerfd.h>
#include <wayland-client.h>
#include <xkbcommon/xkbcommon.h>

#define LENGTH(X) (sizeof (X) / sizeof (X)[0])

#include "drwl/drwl.h"
#include "drwl/bufpool.h"
#include "wlr-layer-shell-unstable-v1-protocol.h"

static char *body;
static int mw, mh;
static int32_t scale = 1;
static bool configured = false;

static sem_t *mutex;

static struct wl_display *display;
static struct wl_compositor *compositor;
static struct wl_seat *seat;
static struct wl_shm *shm;
static struct zwlr_layer_shell_v1 *layer_shell;
static struct zwlr_layer_surface_v1 *layer_surface;
static struct wl_surface *surface;
static struct wl_registry *registry;
static struct wl_pointer *pointer;
static Drwl *drw;
static BufPool pool;
/* default output supplied by compositor */
static struct wl_output *output = NULL; 

static int signal_fd = -1;

#include "config.h"

static void
noop()
{
	/*
	 * meow :3c
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
parse_color(uint32_t *dest, const char *src)
{
	int len;

	if (src[0] == '#')
		src++;
	len = strlen(src);
	if (len != 6 && len != 8)
		die("bad color: %s", src);

	*dest = strtoul(src, NULL, 16);
	if (len == 6)
		*dest = (*dest << 8) | 0xFF;
}

static void
loadfonts(void)
{
	char fontattrs[12];

	drwl_font_destroy(drw->font);
	snprintf(fontattrs, sizeof(fontattrs), "dpi=%d", 96 * scale);
	if (!(drwl_font_create(drw, LENGTH(fonts), fonts, fontattrs)))
		die("no fonts could be loaded");
}

static void
cleanup(void)
{
	bufpool_cleanup(&pool);
	drwl_setimage(drw, NULL);
	drwl_destroy(drw);
	drwl_fini();

	wl_pointer_destroy(pointer);
	zwlr_layer_shell_v1_destroy(layer_shell);
	wl_shm_destroy(shm);
	wl_compositor_destroy(compositor);
	wl_registry_destroy(registry);
	wl_display_disconnect(display);
}

static void
drawmenu(void)
{
	DrwBuf *buf;

	errno = 0;
	if (!(buf = bufpool_getbuf(&pool, shm, mw, mh)))
		die(errno ? "bufpool_getbuf:" : "no buffer available");
	drwl_setimage(drw, buf->image);

	drwl_setscheme(drw, color);
	drwl_text(drw, borderpx, borderpx, mw, mh, padding, body, 0, 1);
	if (borderpx) {
		drwl_setscheme(drw, (uint32_t[]){color[2]});
		drwl_rect(drw, 0, 0, mw, mh, borderpx, 0);
	}

	drwl_setimage(drw, NULL);
	wl_surface_set_buffer_scale(surface, scale);
	wl_surface_attach(surface, buf->wl_buf, 0, 0);
	wl_surface_damage_buffer(surface, 0, 0, mw, mh);
	wl_surface_commit(surface);
}

static void
layer_surface_handle_configure(void *data,
	struct zwlr_layer_surface_v1* layer_surface,
	uint32_t serial, uint32_t width, uint32_t height)
{
	if (configured && mw / scale == width && mh / scale == height)
		return;

	mw = width * scale;
	mh = height * scale;
	zwlr_layer_surface_v1_ack_configure(layer_surface, serial);
	drawmenu();
	configured = true;
}

static void
layer_surface_handle_closed(void *data,
	struct zwlr_layer_surface_v1 *layer_surface)
{
	raise(SIGTERM);
}

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {
	.configure = layer_surface_handle_configure,
	.closed = layer_surface_handle_closed,
};

static void 
surface_handle_preferred_scale(void *data,
	struct wl_surface *wl_surface, int32_t factor)
{
	if (scale == factor)
		return;

	scale = factor;
	loadfonts();
	zwlr_layer_surface_v1_set_size(layer_surface, mw / scale, mh / scale);
	drawmenu();
}

static const struct wl_surface_listener surface_listener = {
	.enter = noop,
	.leave = noop,
	.preferred_buffer_scale = surface_handle_preferred_scale,
	.preferred_buffer_transform = noop,
};

static void
pointer_handle_button(void *data, struct wl_pointer *wl_pointer,
	uint32_t serial, uint32_t time, uint32_t button, uint32_t state)
{
	raise(button == BTN_LEFT ? SIGUSR1 : SIGUSR2);
}

static const struct wl_pointer_listener pointer_listener = {
	.enter = noop,
	.leave = noop,
	.motion = noop,
	.axis = noop,
	.frame = noop,
	.axis_discrete = noop,
	.axis_source = noop,
	.axis_stop = noop,
	.button = pointer_handle_button,
};

static void
seat_handle_capabilities(void *data, struct wl_seat *wl_seat, enum wl_seat_capability caps)
{
	if (!(caps & WL_SEAT_CAPABILITY_KEYBOARD))
		return;

	pointer = wl_seat_get_pointer(seat);
	wl_pointer_add_listener(pointer, &pointer_listener, NULL);
}

static const struct wl_seat_listener seat_listener = {
	.capabilities = seat_handle_capabilities,
	.name = noop,
};


static void
output_handle_name(void *data, struct wl_output *wl_output, const char *name)
{
	if (output_name && !strcmp(name, output_name))
		output = wl_output;
	else
		wl_output_destroy(wl_output);
}

static const struct wl_output_listener output_listener = {
	.geometry = noop,
	.mode = noop,
	.done = noop,
	.scale = noop,
	.name = output_handle_name,
	.description = noop,
};

static void
registry_handle_global(void *data, struct wl_registry *registry,
		uint32_t name, const char *interface, uint32_t version)
{
	if (!strcmp(interface, wl_compositor_interface.name))
		compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 6);
 	else if (!strcmp(interface, wl_shm_interface.name))
		shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
	else if (!strcmp(interface, zwlr_layer_shell_v1_interface.name))
		layer_shell = wl_registry_bind(registry, name,
			&zwlr_layer_shell_v1_interface, 1);
	else if (!strcmp(interface, wl_seat_interface.name)) {
		seat = wl_registry_bind (registry, name, &wl_seat_interface, 4);
		wl_seat_add_listener(seat, &seat_listener, NULL);
	} else if (!strcmp(interface, wl_output_interface.name)) {
		struct wl_output *output = wl_registry_bind(registry, name,
			&wl_output_interface, 4);
		wl_output_add_listener(output, &output_listener, NULL);
	}
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_handle_global,
	.global_remove = noop,
};

static int
run(void)
{
	struct pollfd pfds[] = {
		{ .fd = wl_display_get_fd(display), .events = POLLIN },
		{ .fd = signal_fd,                  .events = POLLIN },
	};

	for (;;) {
		wl_display_flush(display);

		while (poll(pfds, 3, -1) < 0) {
			perror("poll:");
			return 1;
		}

		if (pfds[0].revents & POLLIN)
			if (wl_display_dispatch(display) < 0) {
				fputs("display dispatch failed", stderr);
				return 1;
			}


		if (pfds[1].revents & POLLIN) {
			struct signalfd_siginfo si;
			read(signal_fd, &si, sizeof(si));
			if (si.ssi_signo == SIGUSR1)
				return 0;
			else if (si.ssi_signo == SIGUSR2)
				return 2;
			else if (si.ssi_signo == SIGTERM ||
			         si.ssi_signo == SIGINT)
				break;
		}
	}

	return 0;
}

static void
setup(void)
{
	sigset_t mask;
	Extents e;

	if (!(display = wl_display_connect(NULL)))
		die("failed to connect to wayland");

	registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);
	wl_display_roundtrip(display); /* output & seat listeners */

	if (!compositor || !shm || !layer_shell)
		die("compositor unsupported");
	if (output_name && !output)
		die("output %s not found", output_name);

	sigemptyset(&mask);
	sigaddset(&mask, SIGALRM);
	sigaddset(&mask, SIGINT);
	sigaddset(&mask, SIGTERM);
	sigaddset(&mask, SIGUSR1);
	sigaddset(&mask, SIGUSR2);
	if (duration > 0)
		alarm(duration);

	if (sigprocmask(SIG_BLOCK, &mask, NULL) < 0)
		die("sigprocmask:");
	if ((signal_fd = signalfd(-1, &mask, SFD_NONBLOCK)) < 0)
		die("signalfd:");
		
	drwl_init();
	if (!(drw = drwl_create()))
		die("cannot create drwl drawing context");
	loadfonts();

	surface = wl_compositor_create_surface(compositor);
	wl_surface_add_listener(surface, &surface_listener, NULL);

	e = drwl_text(drw, 0, 0, max_width, max_height, padding, body, 0, 0);
	mw = e.width + borderpx * 2;
	mh = e.height + borderpx * 2;

	layer_surface = zwlr_layer_shell_v1_get_layer_surface(layer_shell,
		surface, output, ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY, "notifications");
	zwlr_layer_surface_v1_set_size(layer_surface, mw, mh);
	zwlr_layer_surface_v1_set_margin(layer_surface,
		margin, margin, margin, margin);
	zwlr_layer_surface_v1_set_anchor(layer_surface, anchor);
	zwlr_layer_surface_v1_set_exclusive_zone(layer_surface, 0);
	zwlr_layer_surface_v1_set_keyboard_interactivity(layer_surface, 0);
	zwlr_layer_surface_v1_add_listener(layer_surface, &layer_surface_listener, NULL);
	wl_surface_commit(surface);
}

int
main(int argc, char *argv[])
{
	int opt, ret;
	static const char usage[] = "usage: %s [-d duration] [-f font] [-h] body\n";

	while ((opt = getopt(argc, argv, "d:f:oh")) != -1)  {
		switch (opt) {
		case 'd':
			duration = atoi(optarg);
			break;
		case 'f':
			fonts[0] = optarg;
			break;
		case 'o':
			output_name = optarg;
			break;
		case 'h':
		default:
			goto usage;
		}
	}
	if ((argc - optind) != 1)
		goto usage;

	body = argv[optind];

	setup();

	mutex = sem_open("/tsubu", O_CREAT, 0644, 1);
	sem_wait(mutex);
	ret = run();

	cleanup();
	sem_post(mutex);
	sem_close(mutex);
	
	return ret;
usage:
	fprintf(stderr, usage, argv[0]);
	sem_unlink("/tsubu"); /* edge cases for unexpected process termination */
	return opt == 'h' ? EXIT_SUCCESS : EXIT_FAILURE;
}
