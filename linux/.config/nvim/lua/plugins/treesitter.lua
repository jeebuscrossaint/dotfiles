-- lua/plugins/treesitter.lua
-- Syntax highlighting, indentation and text objects from a real parse tree.
-- Parsers install on first use; :TSInstall <lang> does it by hand.

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- the stable API (the new `main` branch is a rewrite with breaking changes)
  build = ":TSUpdate", -- keep parsers up to date after plugin updates
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    -- Parsers to always have installed. Add your languages here.
    ensure_installed = {
      "lua", "vim", "vimdoc", "bash", "fish",
      "c", "cpp", "cuda", "rust", "python", "go",
      "json", "yaml", "toml", "markdown", "markdown_inline",
      "html", -- used by leetcode.nvim to render problem descriptions
    },
    auto_install = true, -- automatically install a parser when you open a new filetype
    highlight = { enable = true },
    indent = { enable = true },
  },
}
