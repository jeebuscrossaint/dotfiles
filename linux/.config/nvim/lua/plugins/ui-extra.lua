-- lua/plugins/ui-extra.lua
-- Purely visual. Nothing else depends on any of it.

return {
  -- ── Buffer tabs across the top (VS Code style) ─────────────────────────────
  -- Shows your open files as tabs. You already cycle them with <Tab>/<S-Tab>.
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",     -- show error/warning counts on each tab
        show_buffer_close_icons = true,
        separator_style = "slant",
        offsets = {
          { filetype = "neo-tree", text = "Files", separator = true, text_align = "left" },
        },
      },
    },
  },

  -- ── Command line, messages & popups ────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- the toast-style notification popups (top right)
    },
    opts = {
      lsp = {
        -- Render LSP hover/signature docs with Treesitter markdown highlighting
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,         -- classic bottom search box for "/"
        command_palette = true,       -- ":" and search share a centered popup
        long_message_to_split = true, -- big messages open in a split, not a modal
        lsp_doc_border = true,        -- bordered hover/signature windows
      },
    },
  },

  -- Pretty notifications used by noice (and available as vim.notify everywhere).
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      timeout = 3000,
      render = "compact",
      stages = "fade",
    },
  },

  -- ── Nicer input / selection popups (LSP rename, code actions) ──────────────
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
