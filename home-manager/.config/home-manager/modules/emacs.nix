{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Install language servers
  home.packages = with pkgs; [
    nil          # Nix LSP
    rust-analyzer # Rust LSP
    clang-tools   # Contains clangd for C/C++
    zls          # Zig LSP
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages = epkgs: with epkgs; [
      # Package management
      use-package
      
      # LSP stuff
      lsp-mode
      lsp-ui
      company
      flycheck
      
      # Language modes
      nix-mode
      rust-mode
      python-mode
      go-mode
      
      # Basic QoL
      which-key
      ivy
      counsel
    ];
    
    extraConfig = ''
      ;; Basic setup
      (setq inhibit-startup-message t)
      (global-display-line-numbers-mode t)
      (setq-default tab-width 4)
      
      ;; Package setup
      (require 'use-package)
      (setq use-package-always-ensure t)
      
      ;; Which-key for discoverability
      (use-package which-key
        :config (which-key-mode))
      
      ;; Ivy for file finding
      (use-package ivy
        :config (ivy-mode 1))
      (use-package counsel
        :config (counsel-mode 1))
      
      ;; Company autocomplete
      (use-package company
        :config
        (global-company-mode)
        (setq company-idle-delay 0.2))
      
      ;; Flycheck
      (use-package flycheck
        :config (global-flycheck-mode))
      
      ;; LSP
      (use-package lsp-mode
        :hook ((nix-mode . lsp)
               (rust-mode . lsp)
               (python-mode . lsp)
               (go-mode . lsp))
        :commands lsp
        :config
        (setq lsp-prefer-flymake nil))
      
      (use-package lsp-ui
        :hook (lsp-mode . lsp-ui-mode))
      
      ;; Language modes
      (use-package nix-mode :mode "\\.nix\\'")
      (use-package rust-mode :mode "\\.rs\\'")
      (use-package zig-mode :mode "\\.zig\\'")
      ;; C/C++ modes are built-in      
      ;; Basic keybinds
      (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    '';
  };
}