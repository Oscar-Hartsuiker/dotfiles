return {
  -- CSS language server + treesitter parser
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "css-lsp" } },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
  },

  -- Live color swatches for hex/rgb/hsl values
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      render = "background", -- or "foreground" / "first_column"
    },
    config = function(_, opts)
      require("nvim-highlight-colors").setup(opts)
    end,
  },
}
