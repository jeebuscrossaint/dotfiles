-- lua/plugins/treesitter.lua
-- ============================================================================
-- Treesitter = accurate syntax highlighting + smart code understanding.
-- It parses your code into a real syntax tree instead of guessing with regex,
-- which gives much better highlighting, indentation, and text objects.
--
-- Language parsers install automatically the first time you open a file type
-- (auto_install = true). You can also run :TSInstall <lang> manually.
-- ============================================================================

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
