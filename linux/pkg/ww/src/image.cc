#include "ww.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include <webp/decode.h>
#include <tiffio.h>
#include <jxl/decode.h>
#include <jxl/decode_cxx.h>

extern "C" {

struct image_data_t 
{
    uint8_t *data;
    int width, height;
    int channels;
};

static image_data_t* load_webp(const char *path) 
{
    if (!path)
        return nullptr;

    FILE *file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "Failed to open WebP file: %s\n", path);
        return nullptr;
    }

    fseek(file, 0, SEEK_END);
    long file_len = ftell(file);
    fseek(file, 0, SEEK_SET);
    // ftell returns -1 on error (a directory, say). Assigning that straight to a
    // size_t made file_size SIZE_MAX and the malloc below merely "failed",
    // reported as out-of-memory rather than a bad file.
    if (file_len <= 0) {
        fprintf(stderr, "Not a readable file: %s\n", path);
        fclose(file);
        return nullptr;
    }
    size_t file_size = (size_t)file_len;

    uint8_t *file_data = (uint8_t*)malloc(file_size);
    if (!file_data) {
        fclose(file);
        return nullptr;
    }

    size_t read = fread(file_data, 1, file_size, file);
    fclose(file);
    
    if (read != file_size) {
        fprintf(stderr, "Failed to read WebP file\n");
        free(file_data);
        return nullptr;
    }

    image_data_t *img = (image_data_t*)malloc(sizeof(image_data_t));
    if (!img) {
        free(file_data);
        return nullptr;
    }

    img->data = WebPDecodeRGBA(file_data, file_size, &img->width, &img->height);
    img->channels = 4;

    free(file_data);

    if (!img->data) {
        fprintf(stderr, "Failed to decode WebP\n");
        free(img);
        return nullptr;
    }

    return img;
}

static image_data_t* load_tiff(const char *path) 
{
    if (!path)
        return nullptr;

    TIFF *tif = TIFFOpen(path, "r");
    if (!tif) {
        fprintf(stderr, "Failed to open TIFF file: %s\n", path);
        return nullptr;
    }

    image_data_t *img = (image_data_t*)malloc(sizeof(image_data_t));
    if (!img) {
        TIFFClose(tif);
        return nullptr;
    }

    // img comes from malloc, so width/height are garbage until set. TIFFGetField
    // can fail (tag absent on a malformed file), and the old code ignored that
    // and allocated from whatever was on the heap.
    uint32_t tw = 0, th = 0;
    if (!TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &tw) ||
        !TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &th) ||
        tw == 0 || th == 0) {
        fprintf(stderr, "TIFF has no usable dimensions: %s\n", path);
        TIFFClose(tif);
        free(img);
        return nullptr;
    }
    img->width = (int)tw;
    img->height = (int)th;
    img->channels = 4;

    // size_t throughout: `w * h * 4` in int overflows at about 23000x23000, and
    // the dimensions come from the file, so they are not ours to trust.
    size_t npixels = (size_t)tw * (size_t)th;
    if (npixels > (size_t)1 << 28) { // ~268M pixels, over 1GiB decoded
        fprintf(stderr, "TIFF too large (%ux%u): %s\n", tw, th, path);
        TIFFClose(tif);
        free(img);
        return nullptr;
    }
    img->data = (uint8_t*)malloc(npixels * 4);
    if (!img->data) {
        TIFFClose(tif);
        free(img);
        return nullptr;
    }

    if (!TIFFReadRGBAImageOriented(tif, img->width, img->height,
                                   (uint32_t*)img->data, ORIENTATION_TOPLEFT, 0)) {
        fprintf(stderr, "Failed to read TIFF image\n");
        free(img->data);
        free(img);
        TIFFClose(tif);
        return nullptr;
    }

    TIFFClose(tif);

    for (size_t i = 0; i < npixels; i++) {
        uint8_t r = img->data[i * 4 + 0];
        uint8_t g = img->data[i * 4 + 1];
        uint8_t b = img->data[i * 4 + 2];
        uint8_t a = img->data[i * 4 + 3];
        
        img->data[i * 4 + 0] = b;
        img->data[i * 4 + 1] = g;
        img->data[i * 4 + 2] = r;
        img->data[i * 4 + 3] = a;
    }

    return img;
}

static image_data_t* load_jxl(const char *path) {
    if (!path) {
        return nullptr;
    }

    FILE *file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "Failed to open JXL file: %s\n", path);
        return nullptr;
    }

    fseek(file, 0, SEEK_END);
    long file_len = ftell(file);
    fseek(file, 0, SEEK_SET);
    // ftell returns -1 on error (a directory, say). Assigning that straight to a
    // size_t made file_size SIZE_MAX and the malloc below merely "failed",
    // reported as out-of-memory rather than a bad file.
    if (file_len <= 0) {
        fprintf(stderr, "Not a readable file: %s\n", path);
        fclose(file);
        return nullptr;
    }
    size_t file_size = (size_t)file_len;

    uint8_t *file_data = (uint8_t*)malloc(file_size);
    if (!file_data) {
        fclose(file);
        return nullptr;
    }

    if (fread(file_data, 1, file_size, file) != file_size) {
        fprintf(stderr, "Failed to read JXL file\n");
        free(file_data);
        fclose(file);
        return nullptr;
    }
    fclose(file);

    auto dec = JxlDecoderMake(nullptr);
    if (!dec) {
        fprintf(stderr, "Failed to create JXL decoder\n");
        free(file_data);
        return nullptr;
    }

    if (JxlDecoderSubscribeEvents(dec.get(), JXL_DEC_BASIC_INFO | JXL_DEC_FULL_IMAGE) != JXL_DEC_SUCCESS) {
        fprintf(stderr, "Failed to subscribe to JXL events\n");
        free(file_data);
        return nullptr;
    }

    JxlDecoderSetInput(dec.get(), file_data, file_size);
    JxlDecoderCloseInput(dec.get());

    image_data_t *img = (image_data_t*)malloc(sizeof(image_data_t));
    if (!img) {
        free(file_data);
        return nullptr;
    }
    img->data = nullptr;
    img->channels = 4;

    JxlBasicInfo info;
    JxlPixelFormat format = {4, JXL_TYPE_UINT8, JXL_NATIVE_ENDIAN, 0};

    for (;;) {
        JxlDecoderStatus status = JxlDecoderProcessInput(dec.get());

        if (status == JXL_DEC_ERROR) {
            fprintf(stderr, "JXL decoder error\n");
            free(file_data);
            free(img);
            return nullptr;
        } else if (status == JXL_DEC_NEED_MORE_INPUT) {
            fprintf(stderr, "JXL decoder needs more input\n");
            free(file_data);
            free(img);
            return nullptr;
        } else if (status == JXL_DEC_BASIC_INFO) {
            if (JxlDecoderGetBasicInfo(dec.get(), &info) != JXL_DEC_SUCCESS) {
                fprintf(stderr, "Failed to get JXL basic info\n");
                free(file_data);
                free(img);
                return nullptr;
            }
            img->width = info.xsize;
            img->height = info.ysize;
        } else if (status == JXL_DEC_NEED_IMAGE_OUT_BUFFER) {
            size_t buffer_size;
            if (JxlDecoderImageOutBufferSize(dec.get(), &format, &buffer_size) != JXL_DEC_SUCCESS) {
                fprintf(stderr, "Failed to get JXL output buffer size\n");
                free(file_data);
                free(img);
                return nullptr;
            }

            img->data = (uint8_t*)malloc(buffer_size);
            if (!img->data) {
                free(file_data);
                free(img);
                return nullptr;
            }

            if (JxlDecoderSetImageOutBuffer(dec.get(), &format, img->data, buffer_size) != JXL_DEC_SUCCESS) {
                fprintf(stderr, "Failed to set JXL output buffer\n");
                free(img->data);
                free(file_data);
                free(img);
                return nullptr;
            }
        } else if (status == JXL_DEC_FULL_IMAGE) {
            break;
        } else if (status == JXL_DEC_SUCCESS) {
            break;
        }
    }

    free(file_data);

    if (!img->data) {
        fprintf(stderr, "Failed to decode JXL image\n");
        free(img);
        return nullptr;
    }

    return img;
}

static image_data_t* load_farbfeld(const char *path) {
    if (!path) {
        return nullptr;
    }

    FILE *file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "Failed to open Farbfeld file: %s\n", path);
        return nullptr;
    }

    uint8_t magic[8];
    if (fread(magic, 1, 8, file) != 8 || memcmp(magic, "farbfeld", 8) != 0) {
        fprintf(stderr, "Invalid Farbfeld magic\n");
        fclose(file);
        return nullptr;
    }

    uint32_t width_be, height_be;
    if (fread(&width_be, 4, 1, file) != 1 || fread(&height_be, 4, 1, file) != 1) {
        fprintf(stderr, "Failed to read Farbfeld dimensions\n");
        fclose(file);
        return nullptr;
    }

    uint32_t width = __builtin_bswap32(width_be);
    uint32_t height = __builtin_bswap32(height_be);

    image_data_t *img = (image_data_t*)malloc(sizeof(image_data_t));
    if (!img) {
        fclose(file);
        return nullptr;
    }

    img->width = width;
    img->height = height;
    img->channels = 4;
    img->data = (uint8_t*)malloc(width * height * 4);

    if (!img->data) {
        free(img);
        fclose(file);
        return nullptr;
    }

    for (uint32_t i = 0; i < width * height; i++) {
        uint16_t rgba[4];
        if (fread(rgba, 2, 4, file) != 4) {
            fprintf(stderr, "Failed to read Farbfeld pixel data\n");
            free(img->data);
            free(img);
            fclose(file);
            return nullptr;
        }

        img->data[i * 4 + 0] = __builtin_bswap16(rgba[0]) >> 8;
        img->data[i * 4 + 1] = __builtin_bswap16(rgba[1]) >> 8;
        img->data[i * 4 + 2] = __builtin_bswap16(rgba[2]) >> 8;
        img->data[i * 4 + 3] = __builtin_bswap16(rgba[3]) >> 8;
    }

    fclose(file);
    return img;
}

static image_data_t* load_image(const char *path) {
    if (!path) {
        return nullptr;
    }

    image_data_t *img = (image_data_t*)malloc(sizeof(image_data_t));
    if (!img) {
        return nullptr;
    }

    // Force load as RGBA (4 channels)
    img->data = stbi_load(path, &img->width, &img->height, &img->channels, 4);
    
    if (!img->data) {
        fprintf(stderr, "stb_image error: %s\n", stbi_failure_reason());
        free(img);
        return nullptr;
    }

    return img;
}



static inline float cubic_hermite(float A, float B, float C, float D, float t) {
    float a = -A / 2.0f + (3.0f * B) / 2.0f - (3.0f * C) / 2.0f + D / 2.0f;
    float b = A - (5.0f * B) / 2.0f + 2.0f * C - D / 2.0f;
    float c = -A / 2.0f + C / 2.0f;
    float d = B;
    return a * t * t * t + b * t * t + c * t + d;
}

static inline uint8_t clamp_u8(float value) {
    if (value < 0.0f) return 0;
    if (value > 255.0f) return 255;
    return (uint8_t)value;
}

static void scale_bilinear(const image_data_t *src, image_data_t *dst) {
    float x_ratio = (float)src->width / (float)dst->width;
    float y_ratio = (float)src->height / (float)dst->height;
    
    for (int y = 0; y < dst->height; y++) {
        for (int x = 0; x < dst->width; x++) {
            float src_x = x * x_ratio;
            float src_y = y * y_ratio;
            
            int x1 = (int)src_x;
            int y1 = (int)src_y;
            int x2 = (x1 + 1 < src->width) ? x1 + 1 : x1;
            int y2 = (y1 + 1 < src->height) ? y1 + 1 : y1;
            
            float x_diff = src_x - x1;
            float y_diff = src_y - y1;
            
            int dst_idx = (y * dst->width + x) * 4;
            
            for (int c = 0; c < 4; c++) {
                int idx_tl = (y1 * src->width + x1) * 4 + c;
                int idx_tr = (y1 * src->width + x2) * 4 + c;
                int idx_bl = (y2 * src->width + x1) * 4 + c;
                int idx_br = (y2 * src->width + x2) * 4 + c;
                
                float top = src->data[idx_tl] * (1.0f - x_diff) + src->data[idx_tr] * x_diff;
                float bottom = src->data[idx_bl] * (1.0f - x_diff) + src->data[idx_br] * x_diff;
                float value = top * (1.0f - y_diff) + bottom * y_diff;
                dst->data[dst_idx + c] = clamp_u8(value);
            }
        }
    }
}

static void scale_bicubic(const image_data_t *src, image_data_t *dst) {
    float x_ratio = (float)src->width / (float)dst->width;
    float y_ratio = (float)src->height / (float)dst->height;
    
    for (int y = 0; y < dst->height; y++) {
        for (int x = 0; x < dst->width; x++) {
            float src_x = x * x_ratio;
            float src_y = y * y_ratio;
            
            int x1 = (int)src_x;
            int y1 = (int)src_y;
            
            float x_diff = src_x - x1;
            float y_diff = src_y - y1;
            
            int dst_idx = (y * dst->width + x) * 4;
            
            for (int c = 0; c < 4; c++) {
                float col[4];
                
                for (int ky = 0; ky < 4; ky++) {
                    int sy = y1 - 1 + ky;
                    sy = (sy < 0) ? 0 : ((sy >= src->height) ? src->height - 1 : sy);
                    
                    float row[4];
                    for (int kx = 0; kx < 4; kx++) {
                        int sx = x1 - 1 + kx;
                        sx = (sx < 0) ? 0 : ((sx >= src->width) ? src->width - 1 : sx);
                        
                        int idx = (sy * src->width + sx) * 4 + c;
                        row[kx] = src->data[idx];
                    }
                    
                    col[ky] = cubic_hermite(row[0], row[1], row[2], row[3], x_diff);
                }
                
                float value = cubic_hermite(col[0], col[1], col[2], col[3], y_diff);
                dst->data[dst_idx + c] = clamp_u8(value);
            }
        }
    }
}

static image_data_t* scale_image(const image_data_t *src, int target_width, int target_height, bool preserve_aspect) {
    if (!src || !src->data) {
        return nullptr;
    }

    int new_width = target_width;
    int new_height = target_height;

    if (preserve_aspect) {
        float src_aspect = (float)src->width / (float)src->height;
        float dst_aspect = (float)target_width / (float)target_height;

        if (src_aspect > dst_aspect) {
            new_width = target_width;
            new_height = (int)(target_width / src_aspect);
        } else {
            new_height = target_height;
            new_width = (int)(target_height * src_aspect);
        }
    }

    image_data_t *scaled = (image_data_t*)malloc(sizeof(image_data_t));
    if (!scaled) {
        return nullptr;
    }

    scaled->width = new_width;
    scaled->height = new_height;
    scaled->channels = 4; // RGBA
    scaled->data = (uint8_t*)malloc(new_width * new_height * 4);
    
    if (!scaled->data) {
        free(scaled);
        return nullptr;
    }

    // Use bicubic scaling for best quality
    // Falls back to bilinear for very large scale factors (>4x)
    float scale_factor = (float)src->width / new_width;
    if (scale_factor > 4.0f || scale_factor < 0.25f) {
        // Use faster bilinear for extreme scaling
        scale_bilinear(src, scaled);
    } else {
        // Use bicubic for normal scaling (best quality)
        scale_bicubic(src, scaled);
    }

    return scaled;
}

// Create a centered/letterboxed image with configurable background
static image_data_t* center_image(const image_data_t *src, int canvas_width, int canvas_height, uint32_t bg_color) {
    if (!src || !src->data) {
        return nullptr;
    }

    image_data_t *canvas = (image_data_t*)malloc(sizeof(image_data_t));
    if (!canvas) {
        return nullptr;
    }

    canvas->width = canvas_width;
    canvas->height = canvas_height;
    canvas->channels = 4;
    canvas->data = (uint8_t*)malloc(canvas_width * canvas_height * 4);
    
    if (!canvas->data) {
        free(canvas);
        return nullptr;
    }
    
    // Fill with background color (RGBA format)
    uint8_t bg_r = (bg_color >> 24) & 0xFF;
    uint8_t bg_g = (bg_color >> 16) & 0xFF;
    uint8_t bg_b = (bg_color >> 8) & 0xFF;
    uint8_t bg_a = bg_color & 0xFF;
    
    for (int i = 0; i < canvas_width * canvas_height; i++) {
        canvas->data[i * 4 + 0] = bg_r;
        canvas->data[i * 4 + 1] = bg_g;
        canvas->data[i * 4 + 2] = bg_b;
        canvas->data[i * 4 + 3] = bg_a;
    }

    // Calculate centering offset
    int offset_x = (canvas_width - src->width) / 2;
    int offset_y = (canvas_height - src->height) / 2;

    // Copy image to center of canvas
    for (int y = 0; y < src->height && (y + offset_y) < canvas_height; y++) {
        if (y + offset_y < 0) continue;
        
        for (int x = 0; x < src->width && (x + offset_x) < canvas_width; x++) {
            if (x + offset_x < 0) continue;
            
            int src_idx = (y * src->width + x) * 4;
            int dst_idx = ((y + offset_y) * canvas_width + (x + offset_x)) * 4;
            
            canvas->data[dst_idx + 0] = src->data[src_idx + 0];
            canvas->data[dst_idx + 1] = src->data[src_idx + 1];
            canvas->data[dst_idx + 2] = src->data[src_idx + 2];
            canvas->data[dst_idx + 3] = src->data[src_idx + 3];
        }
    }

    return canvas;
}

// Public API for loading and processing images with scaling mode
image_data_t* ww_load_image_mode(const char *path, int output_width, int output_height, int mode, uint32_t bg_color) {
    // Check file type
    const char *ext = strrchr(path, '.');
    image_data_t *img = nullptr;
    
    if (ext) {
        ext++;
        if (strcasecmp(ext, "webp") == 0) {
            img = load_webp(path);
        } else if (strcasecmp(ext, "tiff") == 0 || strcasecmp(ext, "tif") == 0) {
            img = load_tiff(path);
        } else if (strcasecmp(ext, "jxl") == 0) {
            img = load_jxl(path);
        } else if (strcasecmp(ext, "ff") == 0) {
            img = load_farbfeld(path);
        }
    }
    
    // Fall back to stb_image for other formats
    if (!img) {
        img = load_image(path);
    }
    if (!img) {
        return nullptr;
    }

    // Handle different scaling modes
    image_data_t *result = nullptr;
    
    switch (mode) {
        case 0: // WW_MODE_FIT - scale to fit with letterboxing
        {
            if (img->width == output_width && img->height == output_height) {
                return img;
            }
            
            image_data_t *scaled = scale_image(img, output_width, output_height, true);
            if (img->data) free(img->data);
            free(img);
            
            if (!scaled) return nullptr;
            
            if (scaled->width != output_width || scaled->height != output_height) {
                result = center_image(scaled, output_width, output_height, bg_color);
                if (scaled->data) free(scaled->data);
                free(scaled);
            } else {
                result = scaled;
            }
            break;
        }
        
        case 1: // WW_MODE_FILL - scale to fill, crop if needed
        {
            float img_aspect = (float)img->width / (float)img->height;
            float out_aspect = (float)output_width / (float)output_height;
            
            int scale_width, scale_height;
            if (img_aspect > out_aspect) {
                // Image is wider - scale by height
                scale_height = output_height;
                scale_width = (int)(output_height * img_aspect);
            } else {
                // Image is taller - scale by width
                scale_width = output_width;
                scale_height = (int)(output_width / img_aspect);
            }
            
            image_data_t *scaled = scale_image(img, scale_width, scale_height, false);
            if (img->data) free(img->data);
            free(img);
            
            if (!scaled) return nullptr;
            
            // Crop to output size if needed
            if (scaled->width != output_width || scaled->height != output_height) {
                result = center_image(scaled, output_width, output_height, bg_color);
                if (scaled->data) free(scaled->data);
                free(scaled);
            } else {
                result = scaled;
            }
            break;
        }
        
        case 2: // WW_MODE_STRETCH - stretch to fill
        {
            result = scale_image(img, output_width, output_height, false);
            if (img->data) free(img->data);
            free(img);
            break;
        }
        
        case 3: // WW_MODE_CENTER - no scaling, just center
        {
            result = center_image(img, output_width, output_height, bg_color);
            if (img->data) free(img->data);
            free(img);
            break;
        }
        
        case 4: // WW_MODE_TILE - repeat image to fill
        {
            result = (image_data_t*)malloc(sizeof(image_data_t));
            if (!result) {
                if (img->data) free(img->data);
                free(img);
                return nullptr;
            }
            
            result->width = output_width;
            result->height = output_height;
            result->channels = 4;
            result->data = (uint8_t*)malloc(output_width * output_height * 4);
            
            if (!result->data) {
                free(result);
                if (img->data) free(img->data);
                free(img);
                return nullptr;
            }
            
            // Tile the image
            for (int y = 0; y < output_height; y++) {
                for (int x = 0; x < output_width; x++) {
                    int src_x = x % img->width;
                    int src_y = y % img->height;
                    int src_idx = (src_y * img->width + src_x) * 4;
                    int dst_idx = (y * output_width + x) * 4;
                    
                    result->data[dst_idx + 0] = img->data[src_idx + 0];
                    result->data[dst_idx + 1] = img->data[src_idx + 1];
                    result->data[dst_idx + 2] = img->data[src_idx + 2];
                    result->data[dst_idx + 3] = img->data[src_idx + 3];
                }
            }
            
            if (img->data) free(img->data);
            free(img);
            break;
        }
        
        default:
            if (img->data) free(img->data);
            free(img);
            return nullptr;
    }

    return result;
}

// Legacy API for backward compatibility
image_data_t* ww_load_image(const char *path, int output_width, int output_height, bool preserve_aspect) {
    return ww_load_image_mode(path, output_width, output_height, preserve_aspect ? 0 : 2, 0x000000FF);
}

void ww_free_image(image_data_t *img) {
    if (!img) {
        return;
    }
    
    // For processed images (scaled/centered), data is malloc'd
    if (img->data) {
        free(img->data);
    }
    free(img);
}

} // extern "C"