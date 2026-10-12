return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  init = function()
    -- Delete snacks explorer keymaps so yazi can take over
    pcall(vim.keymap.del, "n", "<leader>e")
    pcall(vim.keymap.del, "n", "<leader>E")
    pcall(vim.keymap.del, "n", "<leader>fe")
    pcall(vim.keymap.del, "n", "<leader>fE")
  end,
  opts = {
    open_for_directories = false,
    yazi_floating_window_border = "single",
    floating_window_size = {
      width = 0.85,
      height = 0.85,
    },
    keymaps = {
      show_help = "<f1>",
    },
  },
  keys = {
    { "<leader>e", "<cmd>Yazi<cr>", desc = "Open Yazi (file manager)" },
    { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Open Yazi (cwd)" },
  },
}
