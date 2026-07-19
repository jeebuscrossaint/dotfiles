-- lua/plugins/dashboard.lua
-- ============================================================================
-- alpha-nvim = the fancy "start screen" shown when you open `nvim` with no file.
--
-- The banner is a RANDOM "neovim" figlet, drawn fresh on every launch from a
-- ~500-font pack in  assets/neovim_headers.json  (rendered from pyfiglet, the
-- same fonts patorjk.com/software/taag uses). To regenerate/adjust the pack see
-- the note at the bottom of this file.
-- ============================================================================

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Load the big banner pack; fall back to a couple of inline ones if the
    -- JSON is missing (e.g. fresh machine before the repo is fully in place).
    local headers = {
      { [[█▄░█ █▀▀ █▀█ █░█ █ █▀▄▀█]], [[█░▀█ ██▄ █▄█ ▀▄▀ █ █░▀░█]] },
    }
    local path = vim.fn.stdpath("config") .. "/assets/neovim_headers.json"
    if vim.fn.filereadable(path) == 1 then
      local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
      if ok and type(decoded) == "table" and #decoded > 0 then
        headers = decoded
      end
    end

    -- Seed from a high-resolution timer so it varies even between two windows
    -- opened in the same second, then pick one banner.
    math.randomseed((vim.uv or vim.loop).hrtime())
    dashboard.section.header.val = headers[math.random(#headers)]
    dashboard.section.header.opts.hl = "Function" -- colour the banner with the theme's blue

    -- Buttons: [shortcut] label -> action. These use shortcuts you already have.
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("n", "  New file", "<cmd>ene | startinsert<CR>"),
      dashboard.button("c", "  Config", "<cmd>e ~/.config/nvim/init.lua<CR>"),
      dashboard.button("L", "  LeetCode", "<cmd>Leet<CR>"),
      dashboard.button("l", "󰒲  Lazy (plugins)", "<cmd>Lazy<CR>"),
      dashboard.button("m", "  Mason (LSP/tools)", "<cmd>Mason<CR>"),
      dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
    }

    -- Footer: how many plugins loaded, once Lazy reports in.
    alpha.setup(dashboard.opts)
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        dashboard.section.footer.val = ("⚡ %d plugins loaded in %dms")
          :format(stats.count, math.floor(stats.startuptime + 0.5))
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}

-- Regenerating the banner pack:
--   The list lives in assets/neovim_headers.json as an array of banners, where
--   each banner is an array of lines. It was generated with pyfiglet:
--     python3 -m venv /tmp/figenv && /tmp/figenv/bin/pip install pyfiglet
--     # render "neovim" in every font, keep ones <= 82 cols & <= 12 rows, dedupe,
--     # then json.dump the survivors to assets/neovim_headers.json
--   Edit the JSON by hand to add/remove any you love or hate.
