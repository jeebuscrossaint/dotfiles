#include "ww.h"
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <algorithm>

extern void set_error(const char *msg);

struct ww_transition_state 
{
    ww_transition_type_t type;
    float duration;
    float current_time;
    bool active;
    
    uint8_t *old_buffer;
    uint8_t *new_buffer;
    uint8_t *output_buffer;
    
    int width, height, stride;
    
    // for circle transitions
    int circle_center_x;
    int circle_center_y;
};

ww_transition_state *ww_transition_create(ww_transition_type_t type, float duration,
                                         int width, int height) 
{
    if (width <= 0 || height <= 0 || duration <= 0) {
        set_error("Invalid transition parameters");
        return nullptr;
    }
    
    ww_transition_state *state = (ww_transition_state*)calloc(1, sizeof(ww_transition_state));
    if (!state) {
        set_error("Failed to allocate transition state");
        return nullptr;
    }
    
    state->type = type;
    state->duration = duration;
    state->current_time = 0.0f;
    state->active = false;
    state->width = width;
    state->height = height;
    state->stride = width * 4;
    
    size_t buffer_size = width * height * 4;
    
    // allocate buffers
    state->old_buffer = (uint8_t*)malloc(buffer_size);
    state->new_buffer = (uint8_t*)malloc(buffer_size);
    state->output_buffer = (uint8_t*)malloc(buffer_size);
    
    if (!state->old_buffer || !state->new_buffer || !state->output_buffer) {
        free(state->old_buffer);
        free(state->new_buffer);
        free(state->output_buffer);
        free(state);
        set_error("Failed to allocate transition buffers");
        return nullptr;
    }
    
    memset(state->old_buffer, 0, buffer_size);
    memset(state->new_buffer, 0, buffer_size);
    memset(state->output_buffer, 0, buffer_size);
    
    return state;
}

void ww_transition_destroy(ww_transition_state *state) 
{
    if (!state) return;
    
    free(state->old_buffer);
    free(state->new_buffer);
    free(state->output_buffer);
    free(state);
}

static void init_random_circle_center(ww_transition_state *state) 
{
    // pick random point for circle effect
    state->circle_center_x = rand() % state->width;
    state->circle_center_y = rand() % state->height;
}

void ww_transition_start(ww_transition_state *state, const uint8_t *old_data,
                         const uint8_t *new_data) 
{
    if (!state || !old_data || !new_data) 
        return;
    
    size_t buffer_size = state->width * state->height * 4;
    
    memcpy(state->old_buffer, old_data, buffer_size);
    memcpy(state->new_buffer, new_data, buffer_size);
    
    state->current_time = 0.0f;
    state->active = true;
    
    // setup circle transition center
    if (state->type == WW_TRANSITION_CIRCLE_OPEN || 
        state->type == WW_TRANSITION_CIRCLE_CLOSE) {
        init_random_circle_center(state);
    }
}

static float ease_in_out(float t) 
{
    if (t < 0.5f)
        return 2.0f * t * t;
    else
        return 1.0f - 2.0f * (1.0f - t) * (1.0f - t);
}

static inline uint8_t lerp_u8(uint8_t a, uint8_t b, float t) {
    return (uint8_t)(a + (b - a) * t);
}

static void apply_fade_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    size_t pixel_count = state->width * state->height;
    
    for (size_t i = 0; i < pixel_count * 4; i++)
        state->output_buffer[i] = lerp_u8(state->old_buffer[i], state->new_buffer[i], t);
}

static void apply_slide_left_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    int offset = (int)(state->width * t);
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            int src_x = x + offset;
            size_t dst_idx = (y * state->width + x) * 4;
            
            if (src_x < state->width) {
                size_t src_idx = (y * state->width + src_x) * 4;
                memcpy(&state->output_buffer[dst_idx], &state->old_buffer[src_idx], 4);
            } else {
                src_x -= state->width;
                size_t src_idx = (y * state->width + src_x) * 4;
                memcpy(&state->output_buffer[dst_idx], &state->new_buffer[src_idx], 4);
            }
        }
    }
}

static void apply_slide_right_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    int offset = (int)(state->width * t);
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            int src_x = x - offset;
            size_t dst_idx = (y * state->width + x) * 4;
            
            if (src_x >= 0) {
                // Show old buffer sliding out
                size_t src_idx = (y * state->width + src_x) * 4;
                memcpy(&state->output_buffer[dst_idx], &state->old_buffer[src_idx], 4);
            } else {
                // Show new buffer sliding in
                src_x += state->width;
                size_t src_idx = (y * state->width + src_x) * 4;
                memcpy(&state->output_buffer[dst_idx], &state->new_buffer[src_idx], 4);
            }
        }
    }
}

static void apply_slide_up_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    int offset = (int)(state->height * t);
    
    for (int y = 0; y < state->height; y++) {
        int src_y = y + offset;
        
        if (src_y < state->height)
            memcpy(&state->output_buffer[y * state->stride],
                   &state->old_buffer[src_y * state->stride], state->stride);
        else {
            src_y -= state->height;
            memcpy(&state->output_buffer[y * state->stride],
                   &state->new_buffer[src_y * state->stride], state->stride);
        }
    }
}

static void apply_slide_down_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    int offset = (int)(state->height * t);
    
    for (int y = 0; y < state->height; y++) {
        int src_y = y - offset;
        
        if (src_y >= 0)
            memcpy(&state->output_buffer[y * state->stride],
                   &state->old_buffer[src_y * state->stride], state->stride);
        else {
            src_y += state->height;
            memcpy(&state->output_buffer[y * state->stride],
                   &state->new_buffer[src_y * state->stride], state->stride);
        }
    }
}

static void apply_zoom_in_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    float scale = 1.0f + t * 0.5f;
    
    int center_x = state->width / 2;
    int center_y = state->height / 2;
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t dst_idx = (y * state->width + x) * 4;
            
            int src_x = center_x + (int)((x - center_x) / scale);
            int src_y = center_y + (int)((y - center_y) / scale);
            
            if (src_x >= 0 && src_x < state->width && src_y >= 0 && src_y < state->height) {
                size_t src_idx = (src_y * state->width + src_x) * 4;
                for (int c = 0; c < 4; c++)
                    state->output_buffer[dst_idx + c] = lerp_u8(
                        state->old_buffer[src_idx + c],
                        state->new_buffer[dst_idx + c], t);
            } else {
                memcpy(&state->output_buffer[dst_idx], &state->new_buffer[dst_idx], 4);
            }
        }
    }
}

static void apply_zoom_out_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    float scale = 1.0f - t * 0.3f;
    
    int center_x = state->width / 2;
    int center_y = state->height / 2;
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t dst_idx = (y * state->width + x) * 4;
            
            int src_x = center_x + (int)((x - center_x) / scale);
            int src_y = center_y + (int)((y - center_y) / scale);
            
            if (src_x >= 0 && src_x < state->width && src_y >= 0 && src_y < state->height) {
                size_t src_idx = (src_y * state->width + src_x) * 4;
                for (int c = 0; c < 4; c++)
                    state->output_buffer[dst_idx + c] = lerp_u8(
                        state->old_buffer[src_idx + c],
                        state->new_buffer[dst_idx + c], t);
            } else {
                for (int c = 0; c < 4; c++)
                    state->output_buffer[dst_idx + c] = state->new_buffer[dst_idx + c];
            }
        }
    }
}

static void apply_circle_open_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    
    int cx = state->circle_center_x;
    int cy = state->circle_center_y;
    
    // need to calc max radius to cover the whole screen from wherever center is
    float d1 = sqrtf(cx * cx + cy * cy);
    float d2 = sqrtf((state->width - cx) * (state->width - cx) + cy * cy);
    float d3 = sqrtf(cx * cx + (state->height - cy) * (state->height - cy));
    float d4 = sqrtf((state->width - cx) * (state->width - cx) + (state->height - cy) * (state->height - cy));
    
    float max_radius = fmaxf(fmaxf(d1, d2), fmaxf(d3, d4));
    float radius = max_radius * t;
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t idx = (y * state->width + x) * 4;
            
            float dx = x - cx, dy = y - cy;
            float dist = sqrtf(dx * dx + dy * dy);
            
            if (dist < radius)
                memcpy(&state->output_buffer[idx], &state->new_buffer[idx], 4);
            else
                memcpy(&state->output_buffer[idx], &state->old_buffer[idx], 4);
        }
    }
}

static void apply_circle_close_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    
    int cx = state->circle_center_x;
    int cy = state->circle_center_y;
    
    float d1 = sqrtf(cx * cx + cy * cy);
    float d2 = sqrtf((state->width - cx) * (state->width - cx) + cy * cy);
    float d3 = sqrtf(cx * cx + (state->height - cy) * (state->height - cy));
    float d4 = sqrtf((state->width - cx) * (state->width - cx) + (state->height - cy) * (state->height - cy));
    
    float max_radius = fmaxf(fmaxf(d1, d2), fmaxf(d3, d4));
    float radius = max_radius * (1.0f - t);
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t idx = (y * state->width + x) * 4;
            
            float dx = x - cx, dy = y - cy;
            float dist = sqrtf(dx * dx + dy * dy);
            
            if (dist > radius)
                memcpy(&state->output_buffer[idx], &state->new_buffer[idx], 4);
            else
                memcpy(&state->output_buffer[idx], &state->old_buffer[idx], 4);
        }
    }
}

static void apply_wipe_left_transition(ww_transition_state *state, float progress) 
{
    int boundary = (int)(state->width * ease_in_out(progress));
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t idx = (y * state->width + x) * 4;
            memcpy(&state->output_buffer[idx], 
                   x < boundary ? &state->new_buffer[idx] : &state->old_buffer[idx], 4);
        }
    }
}

static void apply_wipe_right_transition(ww_transition_state *state, float progress) 
{
    int boundary = (int)(state->width * (1.0f - ease_in_out(progress)));
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t idx = (y * state->width + x) * 4;
            memcpy(&state->output_buffer[idx], 
                   x >= boundary ? &state->new_buffer[idx] : &state->old_buffer[idx], 4);
        }
    }
}

static void apply_wipe_up_transition(ww_transition_state *state, float progress) 
{
    int boundary = (int)(state->height * (1.0f - ease_in_out(progress)));
    
    for (int y = 0; y < state->height; y++)
        memcpy(&state->output_buffer[y * state->stride],
               y >= boundary ? &state->new_buffer[y * state->stride] : &state->old_buffer[y * state->stride],
               state->stride);
}

static void apply_wipe_down_transition(ww_transition_state *state, float progress) 
{
    int boundary = (int)(state->height * ease_in_out(progress));
    
    for (int y = 0; y < state->height; y++)
        memcpy(&state->output_buffer[y * state->stride],
               y < boundary ? &state->new_buffer[y * state->stride] : &state->old_buffer[y * state->stride],
               state->stride);
}

static void apply_dissolve_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    
    for (int y = 0; y < state->height; y++) {
        for (int x = 0; x < state->width; x++) {
            size_t idx = (y * state->width + x) * 4;
            
            // hash for per-pixel random threshold
            unsigned int hash = (x * 73856093) ^ (y * 19349663);
            float threshold = (hash & 0xFFFF) / 65535.0f;
            
            memcpy(&state->output_buffer[idx], 
                   t > threshold ? &state->new_buffer[idx] : &state->old_buffer[idx], 4);
        }
    }
}

static void apply_pixelate_transition(ww_transition_state *state, float progress) 
{
    float t = ease_in_out(progress);
    
    // block size peaks in the middle
    float peak = 1.0f - fabsf(t - 0.5f) * 2.0f;
    int block_size = 1 + (int)(peak * 32.0f);
    
    for (int y = 0; y < state->height; y += block_size) {
        for (int x = 0; x < state->width; x += block_size) {
            int sample_x = x + block_size / 2;
            int sample_y = y + block_size / 2;
            
            if (sample_x >= state->width) 
                sample_x = state->width - 1;
            if (sample_y >= state->height) 
                sample_y = state->height - 1;
            
            size_t sample_idx = (sample_y * state->width + sample_x) * 4;
            
            uint8_t color[4];
            for (int c = 0; c < 4; c++)
                color[c] = lerp_u8(state->old_buffer[sample_idx + c],
                                   state->new_buffer[sample_idx + c], t);
            
            for (int by = 0; by < block_size && (y + by) < state->height; by++) {
                for (int bx = 0; bx < block_size && (x + bx) < state->width; bx++) {
                    size_t dst_idx = ((y + by) * state->width + (x + bx)) * 4;
                    memcpy(&state->output_buffer[dst_idx], color, 4);
                }
            }
        }
    }
}

bool ww_transition_update(ww_transition_state *state, float delta_time, uint8_t **output_data) 
{
    if (!state || !state->active)
        return false;
    
    state->current_time += delta_time;
    
    if (state->current_time >= state->duration) {
        size_t buffer_size = state->width * state->height * 4;
        memcpy(state->output_buffer, state->new_buffer, buffer_size);
        state->active = false;
        
        if (output_data)
            *output_data = state->output_buffer;
        
        return false;
    }
    
    float progress = state->current_time / state->duration;
    progress = std::max(0.0f, std::min(1.0f, progress));
    
    switch (state->type) {
        case WW_TRANSITION_FADE:
            apply_fade_transition(state, progress);
            break;
            
        case WW_TRANSITION_SLIDE_LEFT:
            apply_slide_left_transition(state, progress);
            break;
            
        case WW_TRANSITION_SLIDE_RIGHT:
            apply_slide_right_transition(state, progress);
            break;
            
        case WW_TRANSITION_SLIDE_UP:
            apply_slide_up_transition(state, progress);
            break;
            
        case WW_TRANSITION_SLIDE_DOWN:
            apply_slide_down_transition(state, progress);
            break;
            
        case WW_TRANSITION_ZOOM_IN:
            apply_zoom_in_transition(state, progress);
            break;
            
        case WW_TRANSITION_ZOOM_OUT:
            apply_zoom_out_transition(state, progress);
            break;
            
        case WW_TRANSITION_CIRCLE_OPEN:
            apply_circle_open_transition(state, progress);
            break;
            
        case WW_TRANSITION_CIRCLE_CLOSE:
            apply_circle_close_transition(state, progress);
            break;
            
        case WW_TRANSITION_WIPE_LEFT:
            apply_wipe_left_transition(state, progress);
            break;
            
        case WW_TRANSITION_WIPE_RIGHT:
            apply_wipe_right_transition(state, progress);
            break;
            
        case WW_TRANSITION_WIPE_UP:
            apply_wipe_up_transition(state, progress);
            break;
            
        case WW_TRANSITION_WIPE_DOWN:
            apply_wipe_down_transition(state, progress);
            break;
            
        case WW_TRANSITION_DISSOLVE:
            apply_dissolve_transition(state, progress);
            break;
            
        case WW_TRANSITION_PIXELATE:
            apply_pixelate_transition(state, progress);
            break;
            
        case WW_TRANSITION_NONE:
        default: {
            size_t buffer_size = state->width * state->height * 4;
            memcpy(state->output_buffer, state->new_buffer, buffer_size);
            state->active = false;
        } break;
    }
    
    if (output_data)
        *output_data = state->output_buffer;
    
    return true;
}

bool ww_transition_is_active(const ww_transition_state *state) 
{
    return state && state->active;
}

float ww_transition_get_progress(const ww_transition_state *state) 
{
    if (!state || !state->active)
        return 1.0f;
    
    float progress = state->current_time / state->duration;
    return std::max(0.0f, std::min(1.0f, progress));
}