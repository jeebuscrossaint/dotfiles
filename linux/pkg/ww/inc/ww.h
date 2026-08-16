#ifndef WW_H
#define WW_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <time.h>

#define WW_VERSION_MAJOR 0
#define WW_VERSION_MINOR 1
#define WW_VERSION_PATCH 0

// file types we support

typedef enum 
{
    WW_TYPE_UNKNOWN = 0,
    WW_TYPE_PNG,
    WW_TYPE_JPEG,
    WW_TYPE_WEBP,
    WW_TYPE_BMP,
    WW_TYPE_TGA,
    WW_TYPE_PNM,
    WW_TYPE_TIFF,
    WW_TYPE_JXL,
    WW_TYPE_FARBFELD,
    WW_TYPE_GIF,
    WW_TYPE_MP4,
    WW_TYPE_WEBM,
    WW_TYPE_SOLID_COLOR,
} ww_filetype_t;

typedef enum 
{
    WW_MODE_FIT = 0,
    WW_MODE_FILL,
    WW_MODE_STRETCH,
    WW_MODE_CENTER,
    WW_MODE_TILE,
} ww_scale_mode_t;

typedef enum 
{
    WW_TRANSITION_NONE = 0,
    WW_TRANSITION_FADE,
    WW_TRANSITION_SLIDE_LEFT,
    WW_TRANSITION_SLIDE_RIGHT,
    WW_TRANSITION_SLIDE_UP,
    WW_TRANSITION_SLIDE_DOWN,
    WW_TRANSITION_ZOOM_IN,
    WW_TRANSITION_ZOOM_OUT,
    WW_TRANSITION_CIRCLE_OPEN,
    WW_TRANSITION_CIRCLE_CLOSE,
    WW_TRANSITION_WIPE_LEFT,
    WW_TRANSITION_WIPE_RIGHT,
    WW_TRANSITION_WIPE_UP,
    WW_TRANSITION_WIPE_DOWN,
    WW_TRANSITION_DISSOLVE,
    WW_TRANSITION_PIXELATE,
} ww_transition_type_t;

typedef struct 
{
    char *name;
    int32_t width, height;
    int32_t refresh_rate;
    int32_t scale;
} ww_output_t;

typedef struct 
{
    const char *file_path;
    ww_filetype_t type;
    const char *output_name;
    bool loop;
    ww_scale_mode_t mode;
    uint32_t bg_color;
    ww_transition_type_t transition;
    float transition_duration;
    int transition_fps;
} ww_config_t;

typedef struct image_data_t image_data_t;
typedef struct video_decoder_t video_decoder_t;

// core functions
int ww_init(void);
void ww_cleanup(void);

ww_filetype_t ww_detect_filetype(const char *path);
int ww_set_wallpaper(const ww_config_t *config);
int ww_set_wallpaper_no_loop(const ww_config_t *config);
int ww_list_outputs(ww_output_t **outputs, int *count);
void ww_dispatch_events(void);

// image loading
image_data_t *ww_load_image(const char *path, int output_width, int output_height, bool preserve_aspect);
image_data_t *ww_load_image_mode(const char *path, int output_width, int output_height, int mode, uint32_t bg_color);
void ww_free_image(image_data_t *img);

// video decoder
video_decoder_t *ww_video_create(const char *path, int target_width, int target_height, bool loop);
image_data_t *ww_video_next_frame(video_decoder_t *decoder);
double ww_video_get_frame_duration(video_decoder_t *decoder);
bool ww_video_is_eof(video_decoder_t *decoder);
void ww_video_seek_start(video_decoder_t *decoder);
void ww_video_destroy(video_decoder_t *decoder);

typedef struct ww_transition_state ww_transition_state;

ww_transition_state *ww_transition_create(ww_transition_type_t type, float duration,
                                          int width, int height);
void ww_transition_destroy(ww_transition_state *state);
void ww_transition_start(ww_transition_state *state, const uint8_t *old_data,
                         const uint8_t *new_data);
bool ww_transition_update(ww_transition_state *state, float delta_time, uint8_t **output_data);
bool ww_transition_is_active(const ww_transition_state *state);
float ww_transition_get_progress(const ww_transition_state *state);

typedef struct 
{
    char **paths;
    int count;
} ww_file_list_t;

int ww_scan_directory(const char *dir_path, ww_file_list_t *file_list, bool recursive);
void ww_free_file_list(ww_file_list_t *file_list);

const char *ww_get_error(void);

#ifdef __cplusplus
}
#endif

#endif