return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- Prevents layout shifting during heavy UI updates
        always_show_bufferline = true,
      },
      highlights = {
        -- Force the main background track of the tab bar to be transparent
        fill = {
          bg = "none",
          fg = "none",
        },
        background = {
          bg = "none",
        },
        tab = {
          bg = "none",
        },
      },
    },
  },
}
