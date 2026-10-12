vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "css", "html", "astro", "json", "yaml" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})
-- Save folds and cursor position when leaving a buffer
vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
  pattern = "*",
  callback = function()
    vim.cmd("silent! mkview")
  end,
})

-- Restore folds and cursor position when entering a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    vim.cmd("silent! loadview")
  end,
})
