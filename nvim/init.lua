-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- Force Neovim to use your Matugen Kitty background instead of drawing a separate one
--vim.cmd([[highlight Normal guibg=NONE ctermbg=NONE]])
--vim.cmd([[highlight NonText guibg=NONE ctermbg=NONE]])
-- Ensure NVIM_PARENT_PID is set properly
if not vim.env.NVIM_PARENT_PID or vim.env.NVIM_PARENT_PID == "" then
  local ppid = vim.loop.os_getppid()
  if ppid then
    vim.env.NVIM_PARENT_PID = tostring(ppid)
  end
end
-- Use Vim's :execute to pass the correct PID value
vim.cmd(string.format("autocmd VimEnter * :silent exec '!kill -s SIGWINCH %s'", vim.env.NVIM_PARENT_PID))

require("markview").setup({
  preview = {
    -- hybrid_modes = { "n" },
    -- linewise_hybrid_mode = true, -- optional: clears by line instead of syntax node
  },
})
