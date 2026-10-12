return {
  "karb94/neoscroll.nvim",
  config = function()
    require("neoscroll").setup({
      -- Enable mouse wheel scrolling animation
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      hide_cursor = false, -- Don't hide cursor while scrolling
      stop_eof = true, -- Stop at end of file
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff limit
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
    })
  end,
}
