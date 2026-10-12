local M = {}

function M.add_entry()
  local journal = "/mnt/space/notebook/journal.md"
  local year = os.date("%Y")
  local month = os.date("%B")
  local date = os.date("%Y-%m-%d")
  local weekday = os.date("%A")
  local time = os.date("%I:%M %p")

  local entry_header = "#### " .. time .. " - "

  local year_header = "# " .. year
  local month_header = "## " .. month .. " " .. year
  local date_header = "### " .. date .. " " .. weekday

  local lines
  local entry_line_num

  if vim.fn.filereadable(journal) == 0 then
    lines = { year_header, "", month_header, "", date_header, "", entry_header }
    entry_line_num = #lines
    vim.fn.writefile(lines, journal)
  else
    lines = vim.fn.readfile(journal)

    -- 1. Check if year header exists
    local has_year = false
    for _, line in ipairs(lines) do
      if line == year_header then
        has_year = true
        break
      end
    end
    if not has_year then
      table.insert(lines, year_header)
      table.insert(lines, "")
    end

    -- 2. Check if month header exists
    local has_month = false
    for _, line in ipairs(lines) do
      if line == month_header then
        has_month = true
        break
      end
    end
    if not has_month then
      table.insert(lines, month_header)
      table.insert(lines, "")
    end

    -- 3. Check if date header exists (exact match)
    local has_date = false
    for _, line in ipairs(lines) do
      if line == date_header then
        has_date = true
        break
      end
    end
    if not has_date then
      table.insert(lines, "")
      table.insert(lines, date_header)
    end

    -- 4. Append entry at bottom
    table.insert(lines, "")
    table.insert(lines, entry_header)
    entry_line_num = #lines

    vim.fn.writefile(lines, journal)
  end

  -- Open journal, jump to the entry header line, and insert at end of it
  vim.cmd("edit " .. journal)
  vim.api.nvim_win_set_cursor(0, { entry_line_num, 0 })
  vim.cmd("startinsert!")
end

return M
