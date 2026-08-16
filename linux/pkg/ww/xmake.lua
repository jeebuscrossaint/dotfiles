set_project("ww")
set_version("0.1.0")
set_languages("c++20")

add_rules("mode.debug", "mode.release")

if is_mode("release") then
    set_optimize("fastest")
    set_strip("all")
    add_vectorexts("sse2", "sse3", "ssse3", "sse4.2", "avx")
end

if is_mode("debug") then
    set_symbols("debug")
    set_optimize("none")
    add_defines("DEBUG")
end

target("ww")
    set_kind("binary")

    add_includedirs("inc")
    add_includedirs("build/protocols")
    add_files("src/*.cc")

    -- wayland stuff
    add_packages("wayland", "wayland-protocols")

    -- image formats (stb handles PNG, JPEG, BMP, TGA, GIF, PNM)
    add_packages("stb", "libwebp", "libtiff", "libjxl")

    -- video support
    add_packages("ffmpeg")

    add_syslinks("pthread", "m", "wayland-client", "avcodec", "avformat", "avutil", "swscale")

    -- protocol files (need to be compiled as C)
    add_files("build/protocols/wlr-layer-shell-unstable-v1-protocol.c", {languages = "c"})
    add_files("build/protocols/xdg-shell-protocol.c", {languages = "c"})

    add_cxxflags("-Wall", "-Wextra", "-Wpedantic")
    add_cxxflags("-fno-exceptions", "-fno-rtti", {force = true})

    if is_mode("release") then
        add_ldflags("-flto")
        add_cxxflags("-flto")
    end

    on_install(function (target)
        os.cp("man/ww.1", "$(installdir)/share/man/man1/")
    end)

    on_install(function (target)
        os.cp("completions/ww.bash", "$(installdir)/share/bash-completion/completions/ww")
        os.cp("completions/_ww", "$(installdir)/share/zsh/site-functions/_ww")
        os.cp("completions/ww.fish", "$(installdir)/share/fish/vendor_completions.d/ww.fish")
    end)
target_end()

add_requires("wayland")
add_requires("wayland-protocols")
add_requires("stb")
add_requires("libwebp")
add_requires("libtiff")
add_requires("libjxl")
add_requires("ffmpeg")
