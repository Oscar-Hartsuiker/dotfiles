return {
  -- We hook into snacks.nvim to keep animations smooth if you use them,
  -- or we map the native Neovim horizontal movements.
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = true,
      bindings = {
        -- OPTION A: For native trackpad side-swipes or tilt-wheels
        ["<ScrollWheelLeft>"] = "zh", -- Scrolls the viewport left
        ["<ScrollWheelRight>"] = "zl", -- Scrolls the viewport right

        -- OPTION B: Browser-style (Hold Shift + Scroll Vertically)
        ["<S-ScrollWheelUp>"] = "zh",
        ["<S-ScrollWheelDown>"] = "zl",
      },
    },
  },
}
