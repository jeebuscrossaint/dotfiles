-- lua/plugins/lsp.lua
-- ============================================================================
-- LSP = Language Server Protocol. This is what gives you: go-to-definition,
-- hover documentation, autocompletion data, rename-across-project, inline
-- error/warning diagnostics, and code actions — the "IDE" features.
--
-- Pieces:
--   mason.nvim          -> installs language servers for you (:Mason to browse)
--   mason-lspconfig     -> bridges mason installs to nvim-lspconfig
--   nvim-lspconfig      -> sensible default configs for each server
--
-- LSP keymaps (set when a server attaches to a buffer — see LspAttach below):
--   grn   rename symbol           gra   code action
--   grr   references              grd   go to definition
--   gri   go to implementation    grt   go to type definition
--   K     hover documentation     <leader>e  show line diagnostic
--   [d / ]d  previous / next diagnostic
-- ============================================================================

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    -- Better Lua LSP experience for editing THIS config (knows about `vim`)
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
  },
  config = function()
    -- Tell language servers about the extra completion capabilities that
    -- blink.cmp provides (snippets, resolve support, etc.). vim.lsp.config("*")
    -- applies these defaults to every server mason-lspconfig enables below.
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
      vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
    end

    -- Which servers to auto-install. Add more as you pick up languages.
    -- Names come from :Mason  (e.g. pyright, rust_analyzer, clangd, gopls...).
    local servers = {
      "lua_ls",  -- Lua (needed for editing your Neovim config)
      "clangd",       -- C / C++ / CUDA (attaches to .c .cpp .cu .cuh automatically)
      "basedpyright", -- Python — types/nav/completion (pyright fork; installs via pip, no npm)
      "ruff",         -- Python — fast linter + formatter (complements basedpyright)
      -- "rust_analyzer",  -- Rust
      -- "gopls",          -- Go
      -- "ts_ls",          -- TypeScript / JavaScript
    }

    -- Per-server tweaks. vim.lsp.config(name, {...}) sets options that get
    -- merged in when mason-lspconfig enables the server below.

    -- clangd (C/C++/CUDA): background index + clang-tidy lints + smart includes.
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",     -- index the whole project for fast go-to-def
        "--clang-tidy",           -- inline lint warnings (great while learning)
        "--header-insertion=iwyu",-- auto-add #include when you use a symbol
        "--completion-style=detailed",
      },
    })

    -- Python: let basedpyright do types/navigation and ruff do linting/formatting.
    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          disableOrganizeImports = true, -- ruff handles imports
          analysis = { typeCheckingMode = "standard" }, -- "basic"/"strict" also valid
        },
      },
    })
    vim.lsp.config("ruff", {
      -- turn off ruff's hover so pyright's (richer) hover wins
      on_attach = function(client) client.server_capabilities.hoverProvider = false end,
    })

    require("mason-lspconfig").setup({
      ensure_installed = servers,
      automatic_enable = true, -- mason-lspconfig enables installed servers for us
    })

    -- Run these keymaps whenever a language server attaches to a buffer.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("coat-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("grn", vim.lsp.buf.rename, "Rename symbol")
        map("gra", vim.lsp.buf.code_action, "Code action")
        map("grd", vim.lsp.buf.definition, "Go to definition")
        map("grr", vim.lsp.buf.references, "References")
        map("gri", vim.lsp.buf.implementation, "Go to implementation")
        map("grt", vim.lsp.buf.type_definition, "Go to type definition")
        map("<leader>e", vim.diagnostic.open_float, "Show line diagnostic")
        map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
        map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
      end,
    })

    -- Show diagnostics as nice inline virtual text + gutter icons.
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
      severity_sort = true,
      float = { border = "rounded", source = true },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
    })
  end,
}
