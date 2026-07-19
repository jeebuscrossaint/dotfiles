-- lua/plugins/completion.lua
-- ============================================================================
-- Autocompletion popup, powered by blink.cmp — the modern, fast completion
-- engine (written partly in Rust). It pulls suggestions from the LSP, the
-- current buffer, snippets, and file paths.
--
-- Default keys inside the completion popup:
--   <C-space>  open / toggle the menu
--   <Tab> / <S-Tab>  move to next / previous item (and jump snippet fields)
--   <CR> (Enter)     accept the selected item
--   <C-e>            close the menu
--   <C-b> / <C-f>    scroll the documentation window
-- ============================================================================

return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",                    -- track tagged releases
  build = "cargo build --release", -- build the fast fuzzy matcher from source (you have cargo)
  dependencies = {
    -- A big collection of ready-made snippets (for/if/function templates, etc.)
    "rafamadriz/friendly-snippets",
  },
  opts = {
    keymap = { preset = "default" }, -- the keys documented above
    appearance = { nerd_font_variant = "mono" },
    completion = {
      -- Show documentation for the highlighted item automatically
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = "rounded" },
    },
    -- Where suggestions come from
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    -- Use the native fuzzy matcher (falls back to Lua if the binary is missing)
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true }, -- show function signature while typing args
  },
}
