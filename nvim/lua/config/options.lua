-- Use terminal colors directly
vim.opt.termguicolors = true

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

-- Folding (obsidian LSP headers + treesitter fallback)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.require('obsidian.lsp.handlers.folding_range').foldexpr()"
vim.opt.foldlevel = 99

vim.opt.viewoptions = { "cursor", "folds" }
