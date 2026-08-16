#include "ww.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cerrno>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <time.h>
#include <poll.h>

#include <wayland-client.h>

extern "C" {
#include "wlr-layer-shell-unstable-v1-client-protocol.h"
}

// ============================================================================
// Data Structures
// ============================================================================

struct ww_state {
    struct wl_display *display;
    struct wl_registry *registry;
    struct wl_compositor *compositor;
    struct wl_shm *shm;
    struct zwlr_layer_shell_v1 *layer_shell;
    
    struct wl_list outputs; // List of ww_output
    
    bool running;
    bool is_animated;
    video_decoder_t *video_decoder;
    const char *wallpaper_path;
};

struct ww_output {
    struct wl_list link;
    struct ww_state *state;
    struct wl_output *wl_output;
    
    uint32_t name; // Registry name
    char *conn_name; // Connector name ("eDP-1"), from wl_output.name (v4+)
    int32_t width;
    int32_t height;
    int32_t refresh;
    int32_t scale;
    char *make;
    char *model;
    
    struct wl_surface *surface;
    struct zwlr_layer_surface_v1 *layer_surface;
    struct wl_buffer *buffer;
    uint8_t *buffer_data;
    size_t buffer_size;
    
    struct wl_callback *frame_callback;
    
    bool configured;
    
    // Transition state
    ww_transition_state *transition;
    uint8_t *old_buffer_data;
    size_t old_buffer_size;
    struct timespec transition_start;
};

struct ww_buffer {
    uint8_t *data;
    size_t size;
    int width;
    int height;
    struct wl_buffer *buffer;
};

static struct ww_state *global_state = nullptr;

// Forward declarations
extern void set_error(const char *msg);
extern image_data_t *ww_load_image_mode(const char *path, int output_width, int output_height, int mode, uint32_t bg_color);
extern void ww_free_image(image_data_t *img);
extern video_decoder_t *ww_video_create(const char *path, int target_width, int target_height, bool loop);
extern image_data_t *ww_video_next_frame(video_decoder_t *decoder);
extern double ww_video_get_frame_duration(video_decoder_t *decoder);
extern void ww_video_destroy(video_decoder_t *decoder);
extern ww_transition_state *ww_transition_create(ww_transition_type_t type, float duration, int width, int height);
extern void ww_transition_destroy(ww_transition_state *state);
extern void ww_transition_start(ww_transition_state *state, const uint8_t *old_data, const uint8_t *new_data);
extern bool ww_transition_update(ww_transition_state *state, float delta_time, uint8_t **output_data);
extern bool ww_transition_is_active(const ww_transition_state *state);

// Access image data internals (opaque type implementation)
struct image_data_t {
    uint8_t *data;
    int width;
    int height;
    int channels;
};

// ============================================================================
// Shared Memory Helpers
// ============================================================================

static int create_shm_file(size_t size) {
    const char *xdg_runtime = getenv("XDG_RUNTIME_DIR");
    if (!xdg_runtime) {
        set_error("XDG_RUNTIME_DIR not set");
        return -1;
    }
    
    char path[256];
    snprintf(path, sizeof(path), "%s/ww-XXXXXX", xdg_runtime);
    
    int fd = mkstemp(path);
    if (fd < 0) {
        set_error("Failed to create temp file");
        return -1;
    }
    
    unlink(path); // Remove file but keep fd
    
    if (ftruncate(fd, size) < 0) {
        set_error("Failed to truncate shared memory file");
        close(fd);
        return -1;
    }
    
    return fd;
}

// Create shared memory buffer
static struct wl_buffer* create_shm_buffer(struct wl_shm *shm, uint8_t **data_out, 
                                          int width, int height) {
    // size_t: `width * 4 * height` in int overflows around 23000x23000, and
    // these dimensions can come from a decoded file.
    if (width <= 0 || height <= 0)
        return nullptr;
    size_t stride = (size_t)width * 4; // RGBA
    size_t size = stride * (size_t)height;
    
    int fd = create_shm_file(size);
    if (fd < 0) {
        return nullptr;
    }
    
    uint8_t *data = (uint8_t*)mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        set_error("Failed to mmap shared memory");
        close(fd);
        return nullptr;
    }
    
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, width, height, 
                                                         stride, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);
    
    *data_out = data;
    return buffer;
}

// ============================================================================
// Wayland Output Callbacks
// ============================================================================

static void output_geometry(void *data, struct wl_output *wl_output,
                           int32_t x, int32_t y,
                           int32_t physical_width, int32_t physical_height,
                           int32_t subpixel,
                           const char *make, const char *model,
                           int32_t transform) {
    (void)wl_output;
    (void)x;
    (void)y;
    (void)physical_width;
    (void)physical_height;
    (void)subpixel;
    (void)transform;
    
    struct ww_output *output = (struct ww_output*)data;
    output->make = strdup(make);
    output->model = strdup(model);
}

static void output_mode(void *data, struct wl_output *wl_output,
                       uint32_t flags, int32_t width, int32_t height,
                       int32_t refresh) {
    (void)wl_output;
    struct ww_output *output = (struct ww_output*)data;
    
    if (flags & WL_OUTPUT_MODE_CURRENT) {
        output->width = width;
        output->height = height;
        output->refresh = refresh;
    }
}

static void output_done(void *data, struct wl_output *wl_output) {
    (void)wl_output;
    struct ww_output *output = (struct ww_output*)data;
    output->configured = true;
}

static void output_scale(void *data, struct wl_output *wl_output, int32_t factor) {
    (void)wl_output;
    struct ww_output *output = (struct ww_output*)data;
    output->scale = factor;
}

static void output_name(void *data, struct wl_output *wl_output, const char *name) {
    // wl_output.name, added in version 4. This is the connector name -- "eDP-1",
    // "HDMI-A-1" -- which is what users actually pass to --output. The geometry
    // event's model field is NOT that: it is often empty or a panel part number.
    (void)wl_output;
    struct ww_output *output = (struct ww_output*)data;
    free(output->conn_name);
    output->conn_name = name ? strdup(name) : NULL;
}

static void output_description(void *data, struct wl_output *wl_output, const char *description) {
    // Available in wl_output version 4+
    (void)data;
    (void)wl_output;
    (void)description;
}

static const struct wl_output_listener output_listener = {
    .geometry = output_geometry,
    .mode = output_mode,
    .done = output_done,
    .scale = output_scale,
    .name = output_name,
    .description = output_description,
};

// ============================================================================
// Layer Surface Callbacks
// ============================================================================

static void layer_surface_configure(void *data, struct zwlr_layer_surface_v1 *layer_surface,
                                    uint32_t serial, uint32_t width, uint32_t height) {
    (void)width;
    (void)height;
    struct ww_output *output = (struct ww_output*)data;
    zwlr_layer_surface_v1_ack_configure(layer_surface, serial);
    output->configured = true;
}

static void layer_surface_closed(void *data, struct zwlr_layer_surface_v1 *layer_surface) {
    (void)data;
    (void)layer_surface;
}

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {
    .configure = layer_surface_configure,
    .closed = layer_surface_closed,
};

// ============================================================================
// Frame Callbacks (for animations)
// ============================================================================

static void frame_callback_handler(void *data, struct wl_callback *callback, uint32_t time);
static void transition_frame_callback_handler(void *data, struct wl_callback *callback, uint32_t time);

static const struct wl_callback_listener frame_listener = {
    .done = frame_callback_handler,
};

static const struct wl_callback_listener transition_frame_listener = {
    .done = transition_frame_callback_handler,
};

// Get time difference in seconds
static float get_time_diff(const struct timespec *start) {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    return (now.tv_sec - start->tv_sec) + (now.tv_nsec - start->tv_nsec) / 1e9f;
}

// Transition frame callback
static void transition_frame_callback_handler(void *data, struct wl_callback *callback, uint32_t time) {
    struct ww_output *output = (struct ww_output*)data;
    (void)time;
    
    if (callback) {
        wl_callback_destroy(callback);
        output->frame_callback = nullptr;
    }
    
    if (!output->transition || !ww_transition_is_active(output->transition)) {
        // Transition complete, clean up
        if (output->old_buffer_data) {
            munmap(output->old_buffer_data, output->old_buffer_size);
            output->old_buffer_data = nullptr;
            output->old_buffer_size = 0;
        }
        if (output->transition) {
            ww_transition_destroy(output->transition);
            output->transition = nullptr;
        }
        return;
    }
    
    // Calculate delta time
    float delta_time = get_time_diff(&output->transition_start);
    output->transition_start.tv_sec = 0;
    output->transition_start.tv_nsec = 0;
    clock_gettime(CLOCK_MONOTONIC, &output->transition_start);
    
    // Update transition
    uint8_t *transition_output = nullptr;
    bool still_active = ww_transition_update(output->transition, delta_time, &transition_output);
    
    if (transition_output && output->buffer_data) {
        // Copy transition output to buffer (RGBA to BGRA conversion).
        //
        // Bounded by buffer_size, not by width*height. The transition is only
        // started when the image and output dimensions match, but nothing
        // re-checks that here -- and output->width/height change under us on a
        // mode switch or hotplug while buffer_size does not, which would walk
        // straight off the end of the mapping.
        size_t pixel_count = (size_t)output->width * (size_t)output->height;
        if (pixel_count > output->buffer_size / 4)
            pixel_count = output->buffer_size / 4;
        for (size_t i = 0; i < pixel_count; i++) {
            uint8_t r = transition_output[i * 4 + 0];
            uint8_t g = transition_output[i * 4 + 1];
            uint8_t b = transition_output[i * 4 + 2];
            uint8_t a = transition_output[i * 4 + 3];
            
            output->buffer_data[i * 4 + 0] = b;
            output->buffer_data[i * 4 + 1] = g;
            output->buffer_data[i * 4 + 2] = r;
            output->buffer_data[i * 4 + 3] = a;
        }
        
        // Attach and commit
        wl_surface_attach(output->surface, output->buffer, 0, 0);
        wl_surface_damage_buffer(output->surface, 0, 0, output->width, output->height);
        
        if (still_active) {
            // Setup next frame callback
            output->frame_callback = wl_surface_frame(output->surface);
            wl_callback_add_listener(output->frame_callback, &transition_frame_listener, output);
        }
        
        wl_surface_commit(output->surface);
    }
    
    // Clean up if transition is done
    if (!still_active) {
        if (output->old_buffer_data) {
            munmap(output->old_buffer_data, output->old_buffer_size);
            output->old_buffer_data = nullptr;
            output->old_buffer_size = 0;
        }
        if (output->transition) {
            ww_transition_destroy(output->transition);
            output->transition = nullptr;
        }
    }
}

static void update_animated_frame(struct ww_output *output) {
    if (!output || !output->state->video_decoder) {
        return;
    }
    
    // Get next frame
    image_data_t *img = ww_video_next_frame(output->state->video_decoder);
    if (!img) {
        // Video ended or error
        return;
    }
    
    // Create new buffer if needed
    size_t needed_size = img->width * img->height * 4;
    if (!output->buffer || output->buffer_size != needed_size) {
        if (output->buffer) {
            wl_buffer_destroy(output->buffer);
            if (output->buffer_data) {
                munmap(output->buffer_data, output->buffer_size);
            }
        }
        
        output->buffer_size = needed_size;
        output->buffer = create_shm_buffer(output->state->shm, &output->buffer_data,
                                          img->width, img->height);
    }
    
    if (!output->buffer) {
        ww_free_image(img);
        return;
    }
    
    // Copy frame data to buffer (convert RGBA to BGRA)
    for (int i = 0; i < img->width * img->height; i++) {
        uint8_t r = img->data[i * 4 + 0];
        uint8_t g = img->data[i * 4 + 1];
        uint8_t b = img->data[i * 4 + 2];
        uint8_t a = img->data[i * 4 + 3];
        
        output->buffer_data[i * 4 + 0] = b;
        output->buffer_data[i * 4 + 1] = g;
        output->buffer_data[i * 4 + 2] = r;
        output->buffer_data[i * 4 + 3] = a;
    }
    
    // Attach and commit
    wl_surface_attach(output->surface, output->buffer, 0, 0);
    wl_surface_damage_buffer(output->surface, 0, 0, img->width, img->height);
    
    // Setup next frame callback
    if (output->frame_callback) {
        wl_callback_destroy(output->frame_callback);
    }
    output->frame_callback = wl_surface_frame(output->surface);
    wl_callback_add_listener(output->frame_callback, &frame_listener, output);
    
    wl_surface_commit(output->surface);
    
    ww_free_image(img);
}

static void frame_callback_handler(void *data, struct wl_callback *callback, uint32_t time) {
    struct ww_output *output = (struct ww_output*)data;
    (void)time;
    
    if (callback) {
        wl_callback_destroy(callback);
        output->frame_callback = nullptr;
    }
    
    update_animated_frame(output);
}

// ============================================================================
// Wayland Registry Callbacks
// ============================================================================

static void registry_global(void *data, struct wl_registry *registry,
                           uint32_t name, const char *interface,
                           uint32_t version) {
    struct ww_state *state = (struct ww_state*)data;
    
    if (strcmp(interface, wl_compositor_interface.name) == 0) {
        state->compositor = (struct wl_compositor*)wl_registry_bind(registry, name, 
                                                      &wl_compositor_interface, 4);
    } else if (strcmp(interface, wl_shm_interface.name) == 0) {
        state->shm = (struct wl_shm*)wl_registry_bind(registry, name, &wl_shm_interface, 1);
    } else if (strcmp(interface, wl_output_interface.name) == 0) {
        struct ww_output *output = (struct ww_output*)calloc(1, sizeof(struct ww_output));
        output->state = state;
        output->name = name;
        output->scale = 1;
        // Bind 4 when the compositor offers it: wl_output.name (the connector
        // name) only exists from version 4. Binding 3, as this did, meant the
        // name event never arrived and every output showed up as "Unknown".
        uint32_t ver = version < 4 ? version : 4;
        output->wl_output = (struct wl_output*)wl_registry_bind(registry, name,
                                                  &wl_output_interface, ver);
        
        wl_output_add_listener(output->wl_output, &output_listener, output);
        wl_list_insert(&state->outputs, &output->link);
    } else if (strcmp(interface, zwlr_layer_shell_v1_interface.name) == 0) {
        state->layer_shell = (struct zwlr_layer_shell_v1*)wl_registry_bind(registry, name,
                                                            &zwlr_layer_shell_v1_interface, 1);
    }
}

static void registry_global_remove(void *data, struct wl_registry *registry,
                                  uint32_t name) {
    (void)data;
    (void)registry;
    (void)name;
    // TODO: Handle output removal
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_global,
    .global_remove = registry_global_remove,
};

// Public API implementation
extern "C" {

int ww_init(void) {
    if (global_state) {
        set_error("Already initialized");
        return -1;
    }
    
    struct ww_state *state = (struct ww_state*)calloc(1, sizeof(struct ww_state));
    if (!state) {
        set_error("Out of memory");
        return -1;
    }
    
    wl_list_init(&state->outputs);
    
    // Connect to Wayland display
    state->display = wl_display_connect(nullptr);
    if (!state->display) {
        set_error("Failed to connect to Wayland display");
        free(state);
        return -1;
    }
    
    // Get registry
    state->registry = wl_display_get_registry(state->display);
    if (!state->registry) {
        set_error("Failed to get registry");
        wl_display_disconnect(state->display);
        free(state);
        return -1;
    }
    
    wl_registry_add_listener(state->registry, &registry_listener, state);
    
    // Roundtrip to get all globals
    wl_display_roundtrip(state->display);
    
    // Check we got the required globals
    if (!state->compositor) {
        set_error("Compositor not available");
        wl_display_disconnect(state->display);
        free(state);
        return -1;
    }
    
    if (!state->shm) {
        set_error("Shared memory not available");
        wl_display_disconnect(state->display);
        free(state);
        return -1;
    }
    
    if (!state->layer_shell) {
        set_error("Layer shell not available (wlr-layer-shell-unstable-v1)");
        wl_display_disconnect(state->display);
        free(state);
        return -1;
    }
    
    // Wait for output configuration
    wl_display_roundtrip(state->display);
    
    global_state = state;
    return 0;
}

void ww_cleanup(void) {
    if (!global_state) {
        return;
    }
    
    struct ww_state *state = global_state;
    
    // Cleanup video decoder
    if (state->video_decoder) {
        ww_video_destroy(state->video_decoder);
    }
    
    // Cleanup outputs
    struct ww_output *output, *tmp;
    wl_list_for_each_safe(output, tmp, &state->outputs, link) {
        if (output->frame_callback) {
            wl_callback_destroy(output->frame_callback);
        }
        if (output->buffer_data) {
            munmap(output->buffer_data, output->buffer_size);
        }
        if (output->buffer) {
            wl_buffer_destroy(output->buffer);
        }
        if (output->layer_surface) {
            zwlr_layer_surface_v1_destroy(output->layer_surface);
        }
        if (output->surface) {
            wl_surface_destroy(output->surface);
        }
        if (output->wl_output) {
            wl_output_destroy(output->wl_output);
        }
        free(output->conn_name);
        free(output->make);
        free(output->model);
        wl_list_remove(&output->link);
        free(output);
    }
    
    if (state->layer_shell) {
        zwlr_layer_shell_v1_destroy(state->layer_shell);
    }
    
    if (state->compositor) {
        wl_compositor_destroy(state->compositor);
    }
    if (state->shm) {
        wl_shm_destroy(state->shm);
    }
    if (state->registry) {
        wl_registry_destroy(state->registry);
    }
    if (state->display) {
        wl_display_disconnect(state->display);
    }
    
    free(state);
    global_state = nullptr;
}

int ww_list_outputs(ww_output_t **outputs, int *count) {
    if (!global_state) {
        set_error("Not initialized");
        return -1;
    }
    
    if (!outputs || !count) {
        set_error("NULL pointer provided");
        return -1;
    }
    
    // Count outputs
    int n = 0;
    struct ww_output *output;
    wl_list_for_each(output, &global_state->outputs, link) {
        n++;
    }
    
    if (n == 0) {
        *outputs = nullptr;
        *count = 0;
        return 0;
    }
    
    // Allocate output array
    ww_output_t *out = (ww_output_t*)calloc(n, sizeof(ww_output_t));
    if (!out) {
        set_error("Out of memory");
        return -1;
    }
    
    // Fill output info
    int i = 0;
    wl_list_for_each(output, &global_state->outputs, link) {
        // Prefer the connector name ("eDP-1"); fall back to the model string
        // for compositors still on wl_output v3, and only then give up.
        if (output->conn_name)
            out[i].name = strdup(output->conn_name);
        else if (output->model && output->model[0])
            out[i].name = strdup(output->model);
        else
            out[i].name = strdup("Unknown");
        out[i].width = output->width;
        out[i].height = output->height;
        out[i].refresh_rate = output->refresh / 1000; // mHz to Hz
        out[i].scale = output->scale;
        i++;
    }
    
    *outputs = out;
    *count = n;
    return 0;
}

int ww_set_wallpaper_no_loop(const ww_config_t *config) {
    if (!global_state) {
        set_error("Not initialized");
        return -1;
    }
    
    if (!config) {
        set_error("Invalid configuration");
        return -1;
    }
    
    // file_path can be null for solid color mode
    if (!config->file_path && config->type != WW_TYPE_SOLID_COLOR) {
        set_error("Invalid configuration: no file path");
        return -1;
    }
    
    struct ww_state *state = global_state;
    
    // Check if this is animated content
    bool is_animated = (config->type == WW_TYPE_GIF || 
                       config->type == WW_TYPE_MP4 || 
                       config->type == WW_TYPE_WEBM);
    
    state->is_animated = is_animated;
    state->wallpaper_path = config->file_path;
    
    // For animated content, create video decoder
    if (is_animated) {
        // Use first output dimensions for decoder
        struct ww_output *first_output = wl_container_of(state->outputs.next, first_output, link);
        if (!first_output->configured) {
            set_error("No configured outputs");
            return -1;
        }
        
        state->video_decoder = ww_video_create(config->file_path, 
                                              first_output->width, 
                                              first_output->height,
                                              config->loop);
        if (!state->video_decoder) {
            return -1;
        }
    }
    
    // A name that matches nothing used to fall straight through this loop
    // without creating a surface, and then block forever in the event loop
    // waiting for a configure that could never arrive. Fail loudly instead.
    if (config->output_name) {
        bool found = false;
        struct ww_output *o;
        wl_list_for_each(o, &state->outputs, link) {
            if (o->conn_name && strcmp(config->output_name, o->conn_name) == 0) {
                found = true;
                break;
            }
        }
        if (!found) {
            char msg[256];
            snprintf(msg, sizeof msg,
                     "No output named '%s' (try: ww --list-outputs)",
                     config->output_name);
            set_error(msg);
            return -1;
        }
    }

    // Iterate through outputs and set wallpaper
    struct ww_output *output;
    wl_list_for_each(output, &state->outputs, link) {
        if (!output->configured) {
            continue;
        }
        
        // Skip if specific output requested and this isn't it
        if (config->output_name && output->conn_name &&
            strcmp(config->output_name, output->conn_name) != 0) {
            continue;
        }
        
        // Check if we should do a transition
        bool should_transition = (config->transition != WW_TRANSITION_NONE && 
                                 config->transition_duration > 0.0f &&
                                 output->buffer_data != nullptr &&
                                 output->buffer_size > 0 &&
                                 !is_animated);
        
        // Save old buffer for transition if needed
        uint8_t *old_buffer_copy = nullptr;
        if (should_transition) {
            old_buffer_copy = (uint8_t*)malloc(output->buffer_size);
            if (old_buffer_copy) {
                memcpy(old_buffer_copy, output->buffer_data, output->buffer_size);
            } else {
                should_transition = false;
            }
        }
        
        // Load image (static or first frame) or create solid color
        image_data_t *img = nullptr;
        
        if (config->type == WW_TYPE_SOLID_COLOR) {
            // Create solid color image
            img = (image_data_t*)malloc(sizeof(image_data_t));
            if (!img) {
                set_error("Out of memory");
                return -1;
            }
            
            img->width = output->width;
            img->height = output->height;
            img->channels = 4;
            img->data = (uint8_t*)malloc(output->width * output->height * 4);
            
            if (!img->data) {
                free(img);
                set_error("Out of memory");
                return -1;
            }
            
            // Fill with solid color
            uint8_t r = (config->bg_color >> 24) & 0xFF;
            uint8_t g = (config->bg_color >> 16) & 0xFF;
            uint8_t b = (config->bg_color >> 8) & 0xFF;
            uint8_t a = config->bg_color & 0xFF;
            
            for (int i = 0; i < output->width * output->height; i++) {
                img->data[i * 4 + 0] = r;
                img->data[i * 4 + 1] = g;
                img->data[i * 4 + 2] = b;
                img->data[i * 4 + 3] = a;
            }
        } else if (is_animated) {
            // Get first frame from video decoder
            img = ww_video_next_frame(state->video_decoder);
            if (!img) {
                set_error("Failed to decode first frame");
                return -1;
            }
        } else {
            // Load static image with scaling mode
            img = ww_load_image_mode(config->file_path, 
                                    output->width, output->height,
                                    config->mode, config->bg_color);
            if (!img) {
                set_error("Failed to load image");
                return -1;
            }
        }
        
        // Create surface
        if (!output->surface) {
            output->surface = wl_compositor_create_surface(state->compositor);
            if (!output->surface) {
                set_error("Failed to create surface");
                ww_free_image(img);
                return -1;
            }
        }
        
        // Create layer surface
        if (!output->layer_surface) {
            output->layer_surface = zwlr_layer_shell_v1_get_layer_surface(
                state->layer_shell, output->surface, output->wl_output,
                ZWLR_LAYER_SHELL_V1_LAYER_BACKGROUND, "wallpaper");
            
            if (!output->layer_surface) {
                set_error("Failed to create layer surface");
                ww_free_image(img);
                return -1;
            }
            
            // Configure layer surface
            zwlr_layer_surface_v1_set_size(output->layer_surface, output->width, output->height);
            zwlr_layer_surface_v1_set_anchor(output->layer_surface,
                ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP |
                ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM |
                ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT |
                ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT);
            zwlr_layer_surface_v1_set_exclusive_zone(output->layer_surface, -1);
            
            zwlr_layer_surface_v1_add_listener(output->layer_surface, 
                                              &layer_surface_listener, output);
            
            wl_surface_commit(output->surface);
            wl_display_roundtrip(state->display);
        }
        
        // Create shared memory buffer
        if (output->buffer) {
            wl_buffer_destroy(output->buffer);
            if (output->buffer_data) {
                munmap(output->buffer_data, output->buffer_size);
            }
        }
        
        output->buffer_size = img->width * img->height * 4;
        output->buffer = create_shm_buffer(state->shm, &output->buffer_data,
                                          img->width, img->height);
        if (!output->buffer) {
            set_error("Failed to create buffer");
            ww_free_image(img);
            return -1;
        }
        
        // Handle transition if requested
        if (should_transition && old_buffer_copy && 
            img->width == output->width && img->height == output->height) {
            
            // Create new buffer data in RGBA format for transition
            uint8_t *new_buffer_rgba = (uint8_t*)malloc(img->width * img->height * 4);
            uint8_t *old_buffer_rgba = (uint8_t*)malloc(img->width * img->height * 4);
            
            if (new_buffer_rgba && old_buffer_rgba) {
                // Copy new image data (already in RGBA)
                memcpy(new_buffer_rgba, img->data, img->width * img->height * 4);
                
                // Convert old buffer from BGRA to RGBA
                int pixel_count = img->width * img->height;
                for (int i = 0; i < pixel_count; i++) {
                    old_buffer_rgba[i * 4 + 0] = old_buffer_copy[i * 4 + 2]; // R
                    old_buffer_rgba[i * 4 + 1] = old_buffer_copy[i * 4 + 1]; // G
                    old_buffer_rgba[i * 4 + 2] = old_buffer_copy[i * 4 + 0]; // B
                    old_buffer_rgba[i * 4 + 3] = old_buffer_copy[i * 4 + 3]; // A
                }
                
                // Create and start transition
                if (output->transition) {
                    ww_transition_destroy(output->transition);
                }
                
                output->transition = ww_transition_create(config->transition, 
                                                         config->transition_duration,
                                                         img->width, img->height);
                
                if (output->transition) {
                    ww_transition_start(output->transition, old_buffer_rgba, new_buffer_rgba);
                    clock_gettime(CLOCK_MONOTONIC, &output->transition_start);
                    
                    // Copy initial frame (first transition frame)
                    uint8_t *transition_output = nullptr;
                    ww_transition_update(output->transition, 0.0f, &transition_output);
                    
                    if (transition_output) {
                        // Convert RGBA to BGRA and copy to buffer
                        for (int i = 0; i < pixel_count; i++) {
                            output->buffer_data[i * 4 + 0] = transition_output[i * 4 + 2]; // B
                            output->buffer_data[i * 4 + 1] = transition_output[i * 4 + 1]; // G
                            output->buffer_data[i * 4 + 2] = transition_output[i * 4 + 0]; // R
                            output->buffer_data[i * 4 + 3] = transition_output[i * 4 + 3]; // A
                        }
                        
                        // Start transition animation
                        wl_surface_attach(output->surface, output->buffer, 0, 0);
                        wl_surface_damage_buffer(output->surface, 0, 0, img->width, img->height);
                        output->frame_callback = wl_surface_frame(output->surface);
                        wl_callback_add_listener(output->frame_callback, &transition_frame_listener, output);
                        wl_surface_commit(output->surface);
                    }
                }
            }
            
            if (new_buffer_rgba) free(new_buffer_rgba);
            if (old_buffer_rgba) free(old_buffer_rgba);
            if (old_buffer_copy) free(old_buffer_copy);
            ww_free_image(img);
            continue; // Skip normal rendering for this output
        }
        
        if (old_buffer_copy) {
            free(old_buffer_copy);
        }
        
        // Normal immediate update (no transition)
        // Copy image data to buffer (convert RGBA to ARGB for Wayland)
        for (int i = 0; i < img->width * img->height; i++) {
            uint8_t r = img->data[i * 4 + 0];
            uint8_t g = img->data[i * 4 + 1];
            uint8_t b = img->data[i * 4 + 2];
            uint8_t a = img->data[i * 4 + 3];
            
            // Wayland WL_SHM_FORMAT_ARGB8888 is native endian ARGB
            // On little-endian (x86), this is stored as BGRA in memory
            output->buffer_data[i * 4 + 0] = b;
            output->buffer_data[i * 4 + 1] = g;
            output->buffer_data[i * 4 + 2] = r;
            output->buffer_data[i * 4 + 3] = a;
        }
        
        // Attach buffer and commit
        wl_surface_attach(output->surface, output->buffer, 0, 0);
        wl_surface_damage_buffer(output->surface, 0, 0, img->width, img->height);
        
        // For animated content, setup frame callback
        if (is_animated) {
            output->frame_callback = wl_surface_frame(output->surface);
            wl_callback_add_listener(output->frame_callback, &frame_listener, output);
        }
        
        wl_surface_commit(output->surface);
        
        ww_free_image(img);
    }
    
    // Flush and ensure compositor processes everything
    wl_display_flush(state->display);
    wl_display_roundtrip(state->display);
    
    return 0;
}

// Dispatch wayland events (non-blocking)
extern "C" void ww_dispatch_events(void) {
    if (!global_state) {
        return;
    }
    
    // Prepare to read events
    while (wl_display_prepare_read(global_state->display) != 0) {
        wl_display_dispatch_pending(global_state->display);
    }
    
    // Flush outgoing requests
    wl_display_flush(global_state->display);
    
    // Use poll to check if there are events to read (non-blocking)
    struct pollfd pfd = {
        .fd = wl_display_get_fd(global_state->display),
        .events = POLLIN,
        .revents = 0
    };
    
    // Poll with 0 timeout for non-blocking behavior
    int ret = poll(&pfd, 1, 0);
    
    if (ret > 0 && (pfd.revents & POLLIN)) {
        // Read events from the file descriptor
        wl_display_read_events(global_state->display);
        // Dispatch the events
        wl_display_dispatch_pending(global_state->display);
    } else {
        // Cancel the read
        wl_display_cancel_read(global_state->display);
    }
    
    // Dispatch any remaining pending events
    wl_display_dispatch_pending(global_state->display);
    wl_display_flush(global_state->display);
}

// Set wallpaper and run blocking event loop
int ww_set_wallpaper(const ww_config_t *config) {
    int result = ww_set_wallpaper_no_loop(config);
    if (result != 0) {
        return result;
    }
    
    // Keep running to maintain the wallpaper
    // The compositor needs the client to stay alive
    struct ww_state *state = global_state;
    state->running = true;
    while (state->running && wl_display_dispatch(state->display) != -1) {
        // Process Wayland events
    }
    
    return 0;
}

} // extern "C"