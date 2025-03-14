
{
programs.fd = {
  enable = true;
  hidden = true;  # Search hidden files and directories
  ignores = [
    ".git/"
    "node_modules/"
    ".cache/"
    "*.tmp"
    "*.temp"
    "target/"  # Rust build directory
    "dist/"    # Common build output directory
    "/proc/"
    "/nix/store/"
  ];
  extraOptions = [
    "--follow"  # Follow symbolic links
    "--color=always"  # Always colorize output
  ];
};
}
