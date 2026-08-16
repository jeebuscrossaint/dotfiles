#include "ww.h"
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <sys/stat.h>
#include <dirent.h>
#include <vector>
#include <string>
#include <algorithm>

static thread_local char error_buffer[256] = {0};

void set_error(const char *msg) 
{
    snprintf(error_buffer, sizeof(error_buffer), "%s", msg);
}

const char *ww_get_error(void) 
{
    return error_buffer;
}

ww_filetype_t ww_detect_filetype(const char *path) 
{
    if (!path) {
        set_error("NULL path provided");
        return WW_TYPE_UNKNOWN;
    }

    struct stat st;
    if (stat(path, &st) != 0) {
        set_error("File does not exist");
        return WW_TYPE_UNKNOWN;
    }

    const char *ext = strrchr(path, '.');
    if (!ext) {
        set_error("No file extension found");
        return WW_TYPE_UNKNOWN;
    }

    ext++;

    // check image types
    if (strcasecmp(ext, "png") == 0)
        return WW_TYPE_PNG;
    else if (strcasecmp(ext, "jpg") == 0 || strcasecmp(ext, "jpeg") == 0)
        return WW_TYPE_JPEG;
    else if (strcasecmp(ext, "webp") == 0)
        return WW_TYPE_WEBP;
    else if (strcasecmp(ext, "bmp") == 0)
        return WW_TYPE_BMP;
    else if (strcasecmp(ext, "tga") == 0)
        return WW_TYPE_TGA;
    else if (strcasecmp(ext, "pnm") == 0 || strcasecmp(ext, "pbm") == 0 || 
               strcasecmp(ext, "pgm") == 0 || strcasecmp(ext, "ppm") == 0)
        return WW_TYPE_PNM;
    else if (strcasecmp(ext, "tiff") == 0 || strcasecmp(ext, "tif") == 0)
        return WW_TYPE_TIFF;
    else if (strcasecmp(ext, "jxl") == 0)
        return WW_TYPE_JXL;
    else if (strcasecmp(ext, "ff") == 0)
        return WW_TYPE_FARBFELD;
    else if (strcasecmp(ext, "gif") == 0)
        return WW_TYPE_GIF;
    else if (strcasecmp(ext, "mp4") == 0)
        return WW_TYPE_MP4;
    else if (strcasecmp(ext, "webm") == 0)
        return WW_TYPE_WEBM;

    set_error("Unsupported file extension");
    return WW_TYPE_UNKNOWN;
}

static bool is_supported_image(const char *filename) 
{
    ww_filetype_t type = ww_detect_filetype(filename);
    return type != WW_TYPE_UNKNOWN;
}

static void scan_directory_recursive(const char *dir_path, std::vector<std::string> &files, bool recursive) 
{
    DIR *dir = opendir(dir_path);
    if (!dir)
        return;
    
    struct dirent *entry;
    while ((entry = readdir(dir)) != nullptr) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
            continue;
        
        std::string full_path = std::string(dir_path) + "/" + entry->d_name;
        
        struct stat st;
        if (stat(full_path.c_str(), &st) != 0)
            continue;
        
        if (S_ISDIR(st.st_mode) && recursive)
            scan_directory_recursive(full_path.c_str(), files, recursive);
        else if (S_ISREG(st.st_mode) && is_supported_image(entry->d_name))
            files.push_back(full_path);
    }
    
    closedir(dir);
}

int ww_scan_directory(const char *dir_path, ww_file_list_t *file_list, bool recursive) 
{
    if (!dir_path || !file_list) {
        set_error("NULL pointer provided");
        return -1;
    }
    
    struct stat st;
    if (stat(dir_path, &st) != 0) {
        set_error("Directory does not exist");
        return -1;
    }
    
    if (!S_ISDIR(st.st_mode)) {
        set_error("Path is not a directory");
        return -1;
    }
    
    std::vector<std::string> files;
    scan_directory_recursive(dir_path, files, recursive);
    
    if (files.empty()) {
        set_error("No supported image files found in directory");
        return -1;
    }
    
    std::sort(files.begin(), files.end());
    
    file_list->count = files.size();
    file_list->paths = (char **)malloc(sizeof(char *) * files.size());
    
    if (!file_list->paths) {
        set_error("Memory allocation failed");
        return -1;
    }
    
    for (size_t i = 0; i < files.size(); i++) {
        file_list->paths[i] = strdup(files[i].c_str());
        if (!file_list->paths[i]) {
            // cleanup on failure
            for (size_t j = 0; j < i; j++)
                free(file_list->paths[j]);
            free(file_list->paths);
            set_error("Memory allocation failed");
            return -1;
        }
    }
    
    return 0;
}

void ww_free_file_list(ww_file_list_t *file_list) 
{
    if (!file_list || !file_list->paths)
        return;
    
    for (int i = 0; i < file_list->count; i++)
        free(file_list->paths[i]);
    
    free(file_list->paths);
    file_list->paths = nullptr;
    file_list->count = 0;
}

