return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    cmd = "Obsidian",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "notebook",
          path = "/mnt/space/notebook",
        },
      },
      ui = { enable = false },
      notes_subdir = nil,
      picker = {
        name = "snacks.picker",
      },
      search = {
        sort_by = "modified",
        sort_reversed = true,
      },
      templates = {
        folder = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      daily_notes = {
        folder = "Daily-Notes",
        date_format = "%Y-%m-%d",
        alias_format = "%B %d, %Y",
        template = "daily.md",
      },
      checkbox = {
        order = { " ", "x" },
      },
      attachments = {
        folder = "assets",
        img_name_func = function()
          return "Pasted image " .. os.date("%Y-%m-%d-%H-%M-%S")
        end,
        img_text_func = function(client, path)
          local relative_path = client:relative_to_note(path)
          return string.format("![%s](%s)", vim.fs.basename(relative_path), relative_path)
        end,
      },
      frontmatter = {
        enabled = true,
      },
      note_id_func = function(title)
        return title
      end,
    },

    callbacks = {
      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,
      enter_note = function(note)
        vim.keymap.set("n", "<leader>mc", "<cmd>Obsidian toggle_checkbox<cr>", {
          buffer = true,
          desc = "Toggle checkbox",
        })
        vim.keymap.set("n", "gf", function()
          return require("obsidian").util.gf_passthrough()
        end, { buffer = true, noremap = false, expr = true, desc = "Follow link" })
      end,
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    opts = {
      markdown_inline = {
        tags = {
          enable = false,
        },
      },
    },
    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
  },
}
