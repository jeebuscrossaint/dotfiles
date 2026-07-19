-- lua/plugins/filetree.lua
-- ============================================================================
-- neo-tree = a file-explorer sidebar (like the tree on the left of VS Code).
--
--   <leader>n   toggle the sidebar
--
-- Inside the tree:
--   <CR>  open file / expand folder     a  add file (end name with / for a dir)
--   d     delete       r  rename        c  copy      x  cut      p  paste
--   H     toggle hidden files           ?  show all the tree's keybindings
-- ============================================================================

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>n", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
  },
  opts = {
    close_if_last_window = true, -- don't leave an empty tree as the last window
    filesystem = {
      follow_current_file = { enabled = true }, -- highlight the file you're editing
      use_libuv_file_watcher = true,            -- auto-refresh on external changes
      filtered_items = {
        hide_dotfiles = false, -- you're editing dotfiles — show them!
        hide_gitignored = true,
      },
    },
    window = {
      width = 32,
      mappings = {
        ["<leader>n"] = "close_window",
      },
    },
  },
}
