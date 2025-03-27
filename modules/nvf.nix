{
  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  programs.nvf = {
    enable = true;

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      options = {
        autoindent = true;
        wrap = true;
        #        tabstop = 4;
        #        shiftwidth = 8;
      };

      syntaxHighlighting = true;

      telescope.enable = true;
      spellcheck.enable = true;

      lsp = {
        formatOnSave = true;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = true;
        trouble.enable = true;
        lspSignature.enable = false;
        otter-nvim.enable = false;
        lsplines.enable = false;
        nvim-docs-view.enable = false;
      };

      languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;
        clang.enable = true;
        markdown.enable = true;
        rust.enable = true;
        nix.enable = true;
        python.enable = true;
        go.enable = true;
      };

      visuals = {
        nvim-cursorline.enable = true;
        fidget-nvim.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
        };
      };

      filetree = {
        neo-tree.enable = true;
      };

      assistant = {
        copilot.enable = true;
      };

      ui = {
        borders.enable = true;
        colorizer.enable = true;
      };
      
      terminal = {
      	toggleterm.enable = true;
      };
      
      minimap = {
      	codewindow.enable = true;
      };

      autopairs.nvim-autopairs.enable = true;

      autocomplete.nvim-cmp.enable = true;

      git.enable = true;
    };
  };
}
