return {
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 100,
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },

  {
    "folke/twilight.nvim",
    opts = {},
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
