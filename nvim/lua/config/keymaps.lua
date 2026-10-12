local map = vim.keymap.set

local journal = require("config.journal")

-- ... your other mappings ...

map("n", "<leader>mj", journal.add_entry, { desc = "Journal entry" })
local md = vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    map("n", "<leader>md", function()
      local heading = os.date("## %Y-%m-%d %H:%M")
      vim.api.nvim_put({ heading, "" }, "l", true, true)
    end, { desc = "Paste date block", buffer = args.buf })
    map("n", "<BS>", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks", buffer = args.buf })
  end,
})

-- ── Obsidian ─────────────────────────────────────────────────
map("n", "<leader>mn", "<cmd>Obsidian new<cr>", { desc = "New note" })
map("n", "<leader>mv", "<cmd>Markview toggle<cr>", { desc = "Toggle markview" })
map("n", "<leader>mf", "<cmd>Obsidian quick_switch<cr>", { desc = "Find note" })
map("n", "<leader>mb", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks" })
map("n", "<leader>m#", "<cmd>Obsidian tags<cr>", { desc = "Tags" })
--map("n", "<leader>mD", "<cmd>Obsidian today<cr>", { desc = "Daily" })
map("n", "<leader>ms", "<cmd>Obsidian search<cr>", { desc = "Search notes" })
map("n", "<leader>mr", "<cmd>Obsidian rename<cr>", { desc = "Rename note" })
map("n", "<leader>mi", function()
  require("img-clip").pasteImage()
end, { desc = "Paste image" })
map("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview" })
map("v", "<leader>me", "<cmd>Obsidian extract_note<cr>", { desc = "Extract to note" })
map("v", "<leader>ml", "<cmd>Obsidian link<cr>", { desc = "Link to note" })
map("n", "<leader>mt", "<cmd>Obsidian template<cr>", { desc = "Insert template" })
map("n", "<leader>mT", "<cmd>Obsidian new_from_template<cr>", { desc = "New note from template" })
map("n", "<leader>m0", "<cmd>ObsidianToggleCheckbox<CR>", { desc = "Toggle checkbox" })

-- ── Daily / journal (handled by config/journal.lua) ──────────
-- ── Root / TODO ──────────────────────────────────────────────
map("n", "<leader>m/", "<cmd>edit /mnt/space/notebook/root.md<cr>", { desc = "Root" })
map("n", "<leader>mx", function()
  vim.cmd("edit /mnt/space/notebook/TO-DO.md")
  vim.cmd("normal! G")
end, { desc = "TODO" })

-- ── Navigation ───────────────────────────────────────────────
map("n", "<BS>", "<C-o>", { desc = "Go back" })

map("n", "K", vim.lsp.buf.hover, { desc = "Hover (preview)" })
map("n", "z1", "<cmd>set foldlevel=1<cr>", { desc = "Fold h2 and deeper" })
map("n", "z2", "<cmd>set foldlevel=2<cr>", { desc = "Fold h3 and deeper" })
map("n", "z0", "<cmd>set foldlevel=99<cr>", { desc = "Unfold all" })
