-- lua/plugins/formatting.lua
-- ============================================================================
-- conform.nvim = auto-format your code with the right tool per language
-- (stylua for Lua, black for Python, rustfmt for Rust, prettier for web...).
--
-- Format-on-save is ON. Turn it off for a language by removing it from
-- formatters_by_ft, or comment out the format_on_save block entirely.
--
-- Manual format:  <leader>f
-- NOTE: install the formatter binaries via :Mason or your package manager.
-- ============================================================================

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    -- Map filetypes to formatters. Add your languages here.
    formatters_by_ft = {
      lua = { "stylua" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      cuda = { "clang-format" }, -- clang-format handles .cu / .cuh too
      python = { "ruff_format", "ruff_organize_imports" }, -- format + sort imports
      -- rust = { "rustfmt" },
      -- go = { "gofmt" },
      -- Fallback: trim trailing whitespace on any filetype not listed above
      ["_"] = { "trim_whitespace" },
    },
    -- Format automatically when you save
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback", -- use the LSP formatter if no dedicated one is set
    },
  },
}
