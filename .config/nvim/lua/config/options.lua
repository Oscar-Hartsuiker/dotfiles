vim.cmd.colorscheme = nil
vim.opt.termguicolors = false
vim.cmd("set t_Co=256")
-- Better text editing defaults
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.spell = true
vim.opt.spelllang = "en"
vim.opt.conceallevel = 0

-- Make splits nicer
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"
