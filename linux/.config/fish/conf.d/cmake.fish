# Always emit compile_commands.json from CMake builds.
#
# This is the database clangd (the C/C++/CUDA language server in Neovim) reads
# to know your include paths and compile flags. clangd auto-discovers it in a
# `build/` subdirectory, so with this set you get full IDE features with zero
# per-project effort — just configure your project the normal way:
#
#   cmake -B build
#
# and clangd picks up build/compile_commands.json automatically.
set -gx CMAKE_EXPORT_COMPILE_COMMANDS ON
