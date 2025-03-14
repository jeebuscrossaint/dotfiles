{ config, lib, pkgs, ... }:

{
  programs.man = {
    enable = true;
    # Use the more modern mandoc implementation instead of the default man
    package = pkgs.mandoc;
    # Enable cache generation for faster searches with apropos/man -k
    generateCaches = true;
  };
}
