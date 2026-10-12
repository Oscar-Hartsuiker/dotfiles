return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      pickers = {
        find_files = {
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        live_grep = {
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        buffers = {
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        help_tags = {
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "single",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = {
      window = {
        completion = {
          border = "single",
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
        },
        documentation = {
          border = "single",
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = "single",
        }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = "single",
        }),
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        border = "single",
        preview = {
          border = "single",
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      win = {
        border = "single",
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    opts = {
      config = {
        header = vim.split(string.rep("\n", 8) .. [[
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]], "\n"),
      },
    },
  },
}
