#define _DEFAULT_SOURCE
#include <err.h>
#include <errno.h>
#include <getopt.h>
#include <limits.h>
#include <pwd.h>
#include <shadow.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <wayland-client.h>
#include <xkbcommon/xkbcommon.h>

#include "ext-session-lock-v1-protocol.h"
#include "single-pixel-buffer-v1-protocol.h"
#include "viewporter-protocol.h"

typedef struct {
	unsigned int r, g, b;
} Clr;

typedef struct {
	uint32_t wl_name;
	struct wl_output *wl_output;
	struct wl_surface *surface;
	struct ext_session_lock_surface_v1 *lock_surface;
	struct wp_viewport *viewport;

	int32_t width, height;

	struct wl_list link;
} Output;

static struct {
	char input[256];
	int len;
} pw;

static struct wl_display *display;
static struct xkb_context *xkb_ctx;
static struct wl_registry *registry;
static struct wl_compositor *compositor;
static struct wp_viewporter *viewporter;
static struct wp_single_pixel_buffer_manager_v1 *buf_manager;
static struct ext_session_lock_manager_v1 *lock_manager;
static struct wl_seat *seat;
static struct ext_session_lock_v1 *lock;
static struct wl_pointer *pointer;
static struct wl_keyboard *keyboard;
static struct xkb_keymap *keymap;
static struct xkb_state *xkb_state;

static struct wl_list outputs;

static char *hash;
static bool locked, running;

enum input_state { INIT, FAILED, INPUT, INPUT_ALT } input_state = INIT;

#include "config.h"

static void
noop()
{
	/* 
	 * :3c
	 */
}

static Clr
parse_clr(const char *color)
{
	int len;
	unsigned int res;

	len = strlen(color);
	if (len != 6)
		errx(EXIT_FAILURE, "invalid color given: %s", color);

	res = strtoul(color, NULL, 16);

	return (Clr){
		((res >> 16) & 0xff) * (0xffffffff / 0xff),
		((res >> 8) & 0xff) * (0xffffffff / 0xff),
		((res >> 0) & 0xff) * (0xffffffff / 0xff),
	};
}

static void
output_frame(Output *output)
{
	Clr c = colorname[input_state];
	struct wl_buffer *buffer;
	struct wl_region *opaque = wl_compositor_create_region(compositor);

	/* alpha has no effect on this surface */
	buffer = wp_single_pixel_buffer_manager_v1_create_u32_rgba_buffer(
		buf_manager, c.r, c.g, c.b, 0xffffffff);

	wl_surface_attach(output->surface, buffer, 0, 0);
	wl_surface_damage_buffer(output->surface, 0, 0, INT32_MAX, INT32_MAX);
	wl_region_add(opaque, 0, 0, INT32_MAX, INT32_MAX);
	wl_surface_set_opaque_region(output->surface, opaque);
	wl_region_destroy(opaque);
	wp_viewport_set_destination(output->viewport, output->width, output->height);
	wl_surface_commit(output->surface);

	wl_buffer_destroy(buffer);
}

static void
outputs_frame(void)
{
	Output *output;

	wl_list_for_each(output, &outputs, link)
		output_frame(output);
}

static void
lock_surface_configure(void *data,
		struct ext_session_lock_surface_v1 *lock_surface,
		uint32_t serial, uint32_t width, uint32_t height)
{
	Output *output = data;
	output->width = width;
	output->height = height;

	ext_session_lock_surface_v1_ack_configure(lock_surface, serial);
	output_frame(output);
}

static const struct ext_session_lock_surface_v1_listener lock_surface_listener = {
	.configure = lock_surface_configure,
};

static void
output_create_surface(Output *output)
{
	output->surface = wl_compositor_create_surface(compositor);
	output->lock_surface = ext_session_lock_v1_get_lock_surface(
		lock, output->surface, output->wl_output);
	output->viewport = wp_viewporter_get_viewport(viewporter, output->surface);

	ext_session_lock_surface_v1_add_listener(output->lock_surface, &lock_surface_listener, output);
}

static void
output_destroy(Output *output)
{
	wl_list_remove(&output->link);
	wp_viewport_destroy(output->viewport);
	ext_session_lock_surface_v1_destroy(output->lock_surface);
	wl_surface_destroy(output->surface);
	wl_output_destroy(output->wl_output);
	free(output);
}

static void
outputs_destroy(void)
{
	Output *output, *tmp;

	wl_list_for_each_safe(output, tmp, &outputs, link)
		output_destroy(output);
}

static void
keyboard_keypress(enum wl_keyboard_key_state key_state,
		xkb_keysym_t sym)
{
	int n;
	char buf[8], *inputhash;

	if (key_state != WL_KEYBOARD_KEY_STATE_PRESSED)
		return;

	switch (sym) {
	case XKB_KEY_KP_Enter:
	case XKB_KEY_Return:
		pw.input[pw.len] = '\0';
		errno = 0;
		if (!(inputhash = crypt(pw.input, hash)))
			warn("crypt:");
		else
			running = !!strcmp(inputhash, hash);
		if (running)
			input_state = FAILED;
		explicit_bzero(&pw.input, sizeof(pw.input));
		pw.len = 0;
		break;
	case XKB_KEY_BackSpace:
		if (pw.len)
			pw.input[--pw.len] = '\0';
		break;
	case XKB_KEY_Escape:
		explicit_bzero(&pw.input, sizeof(pw.input));
		pw.len = 0;
		break;
	default:
		if (!xkb_keysym_to_utf8(sym, buf, 8))
			break;
		n = strnlen(buf, 8);
		if (pw.len + n < 256) {
			memcpy(pw.input + pw.len, buf, n);
			pw.len += n;
		}
		break;
	}

	input_state = pw.len ? pw.len % 2 ? INPUT : INPUT_ALT :
	              (input_state == FAILED || failonclear) ? FAILED : INIT;

	outputs_frame();
}

static void
keyboard_handle_keymap(void *data, struct wl_keyboard *wl_keyboard,
		uint32_t format, int32_t fd, uint32_t size)
{
	char *map_shm;

	if (format != WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1)
		errx(EXIT_FAILURE, "unknown keymap %d", format);

	xkb_keymap_unref(keymap);
	xkb_state_unref(xkb_state);

	map_shm = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (map_shm == MAP_FAILED)
		errx(EXIT_FAILURE, "mmap keymap shm failed");

	keymap = xkb_keymap_new_from_buffer(xkb_ctx,
		map_shm, size, XKB_KEYMAP_FORMAT_TEXT_V1, XKB_KEYMAP_COMPILE_NO_FLAGS);
	munmap(map_shm, size);
	close(fd);

	xkb_state = xkb_state_new(keymap);
}

static void
keyboard_handle_key(void *data, struct wl_keyboard *wl_keyboard,
		uint32_t serial, uint32_t time, uint32_t key, uint32_t key_state)
{
	keyboard_keypress((enum wl_keyboard_key_state)key_state,
		xkb_state_key_get_one_sym(xkb_state, key + 8));
}

static void
keyboard_handle_modifiers(void *data, struct wl_keyboard *wl_keyboard,
		uint32_t serial, uint32_t mods_depressed,
		uint32_t mods_latched, uint32_t mods_locked, uint32_t group)
{
	xkb_state_update_mask(xkb_state, mods_depressed, mods_latched,
			mods_locked, 0, 0, group);
}

static const struct wl_keyboard_listener keyboard_listener = {
	.keymap = keyboard_handle_keymap,
	.enter = noop,
	.leave = noop,
	.key = keyboard_handle_key,
	.modifiers = keyboard_handle_modifiers,
	.repeat_info = noop,
};

static void
pointer_handle_enter(void *data, struct wl_pointer *pointer, uint32_t serial,
		struct wl_surface *surface, wl_fixed_t surface_x, wl_fixed_t surface_y)
{
	wl_pointer_set_cursor(pointer, serial, NULL, 0, 0);
}

static const struct wl_pointer_listener pointer_listener = {
	.enter = pointer_handle_enter,
	.leave = noop,
	.motion = noop,
	.button = noop,
	.axis = noop,
};

static void
seat_capabilities(void *data, struct wl_seat *seat,
		enum wl_seat_capability caps)
{
	if (pointer) {
		wl_pointer_release(pointer);
		pointer = NULL;
	}

	if (keyboard) {
		wl_keyboard_release(keyboard);
		keyboard = NULL;
	}

	if (caps & WL_SEAT_CAPABILITY_POINTER) {
		pointer = wl_seat_get_pointer(seat);
		wl_pointer_add_listener(pointer, &pointer_listener, NULL);
	}

	if (caps & WL_SEAT_CAPABILITY_KEYBOARD) {
		keyboard = wl_seat_get_keyboard(seat);
		wl_keyboard_add_listener(keyboard, &keyboard_listener, seat);
	}
}

static const struct wl_seat_listener seat_listener = {
	.capabilities = seat_capabilities,
	.name = noop,
};

static void
registry_global(void *data, struct wl_registry *registry,
		uint32_t name, const char *interface, uint32_t version)
{
	if (!strcmp(interface, wl_compositor_interface.name))
		compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 4);
	else if (!strcmp(interface, wp_viewporter_interface.name))
		viewporter = wl_registry_bind(registry, name, &wp_viewporter_interface, 1);
	else if (!strcmp(interface, wp_single_pixel_buffer_manager_v1_interface.name))
		buf_manager = wl_registry_bind(
			registry, name, &wp_single_pixel_buffer_manager_v1_interface, 1);
	else if (!strcmp(interface, ext_session_lock_manager_v1_interface.name))
		lock_manager = wl_registry_bind(
			registry, name, &ext_session_lock_manager_v1_interface, 1);
	else if (!strcmp(interface, wl_seat_interface.name)) {
		seat = wl_registry_bind(registry, name, &wl_seat_interface, 4);
		wl_seat_add_listener(seat, &seat_listener, NULL);
	} else if (!strcmp(interface, wl_output_interface.name)) {
		Output *output = calloc(1, sizeof(Output));
		output->wl_name = name;
		output->wl_output = wl_registry_bind(registry, name, &wl_output_interface, 4);
		wl_list_insert(&outputs, &output->link);
		if (running)
			output_create_surface(output);
	}
}

static void
registry_global_remove(void *data,
		struct wl_registry *registry, uint32_t name)
{
	Output *output, *tmp;

	wl_list_for_each_safe(output, tmp, &outputs, link) {
		if (output->wl_name == name) {
			output_destroy(output);
			break;
		}
	}
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_global,
	.global_remove = registry_global_remove,
};

static void
lock_locked(void *data, struct ext_session_lock_v1 *lock)
{
	locked = true;
}

static void
lock_finished(void *data, struct ext_session_lock_v1 *lock)
{
	if (!locked)
		errx(EXIT_FAILURE, "another lockscreen is already running");
	warnx("compositor requested unlock");
}

static const struct ext_session_lock_v1_listener lock_listener = {
	.locked = lock_locked,
	.finished = lock_finished,
};

static void
drop(void)
{
	struct spwd *sp;
	struct passwd *p;

	if (!(p = getpwuid(getuid())))
		err(EXIT_FAILURE, NULL);
	hash = p->pw_passwd;
	if (!strcmp(hash, "x")) {
		if (!(sp = getspnam(p->pw_name)))
			errx(EXIT_FAILURE, "getspnam failed, ensure suid & sgid lock");
		hash = sp->sp_pwdp;
	}

	if (!crypt("", hash))
		err(EXIT_FAILURE, NULL);

	if (setgid(getgid()) != 0)
		err(EXIT_FAILURE, NULL);
	if (setuid(getuid()) != 0)
		err(EXIT_FAILURE, NULL);
	if (setuid(0) > 0 || setgid(0) > 0)
		errx(EXIT_FAILURE, "should not able to restore root");
}

static void
setup(void)
{
	Output *output;

	wl_list_init(&outputs);

	if (!(display = wl_display_connect(NULL)))
		errx(EXIT_FAILURE, "wayland display connect failed");

	if (!(xkb_ctx = xkb_context_new(XKB_CONTEXT_NO_FLAGS)))
		errx(EXIT_FAILURE, "xkb_context_new failed");

	registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);

	if (!compositor || !lock_manager || !buf_manager)
		errx(EXIT_FAILURE, "unsupported compositor");

	lock = ext_session_lock_manager_v1_lock(lock_manager);
	ext_session_lock_v1_add_listener(lock, &lock_listener, NULL);
	wl_display_roundtrip(display);

	wl_list_for_each(output, &outputs, link)
		output_create_surface(output);
}

static void
cleanup(void)
{
	ext_session_lock_v1_unlock_and_destroy(lock);
	wl_display_roundtrip(display);

	outputs_destroy();
	xkb_state_unref(xkb_state);
	xkb_keymap_unref(keymap);
	wl_keyboard_destroy(keyboard);
	wl_pointer_destroy(pointer);
	wl_seat_destroy(seat);
	ext_session_lock_manager_v1_destroy(lock_manager);
	wp_single_pixel_buffer_manager_v1_destroy(buf_manager);
	wp_viewporter_destroy(viewporter);
	wl_compositor_destroy(compositor);
	wl_registry_destroy(registry);
	xkb_context_unref(xkb_ctx);
	wl_display_disconnect(display);
}

int
main(int argc, char *argv[])
{
	int opt;

	while ((opt = getopt(argc, argv, "a:c:f:i:vh")) != -1) {
		switch (opt) {
		case 'a':
		case 'c':
		case 'f':
		case 'i':
			colorname[opt == 'f' ? FAILED : opt == 'i' ? INPUT :
			          opt == 'a' ? INPUT_ALT : INIT] = parse_clr(optarg);
			break;
		case 'v':
			puts("wlock " VERSION);
			return EXIT_SUCCESS;
		case 'h':
		default:
			fprintf(stderr, "usage: wlock [-hv] [-a input_alt_color] [-i input_color]\n"
			                "             [-c init_color] [-f fail_color]\n");
			return opt == 'h' ? EXIT_SUCCESS : EXIT_FAILURE;
		}
	}

	drop();
	setup();

	running = true;
	while (running && wl_display_dispatch(display) > 0)
		;

	cleanup();

	return EXIT_SUCCESS;
}
