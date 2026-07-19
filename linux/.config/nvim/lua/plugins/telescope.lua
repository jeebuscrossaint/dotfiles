-- lua/plugins/telescope.lua
-- ============================================================================
-- Telescope = the fuzzy finder. This is the tool you'll use most: find files,
-- search text across the whole project, jump to symbols, browse git, etc.
--
-- Key shortcuts (all under <leader> = Space):
--   <leader>ff  find files by name
--   <leader>fg  live grep — search file CONTENTS across the project
--   <leader>fb  list open buffers
--   <leader>fh  search the built-in help docs
--   <leader>fr  recently opened files
--   <leader>fw  find the word under the cursor
--   <leader>fc  pick a colorscheme (live preview!)
--
-- Inside the picker: type to filter, <C-j>/<C-k> or arrows to move,
-- <Enter> to open, <C-v> to open in a vertical split, <Esc> to close.
-- ============================================================================

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Native fzf sorter for much faster fuzzy matching (compiled with make)
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep (search text in project)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find open buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search help docs" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Find word under cursor" },
    { "<leader>fc", "<cmd>Telescope colorscheme<CR>", desc = "Pick colorscheme" },
    { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find files (quick)" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        -- Ignore noise; ripgrep must be installed for live_grep (see the guide)
        file_ignore_patterns = { "%.git/", "node_modules/", "target/", "%.o", "%.class" },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
