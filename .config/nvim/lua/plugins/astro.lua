return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes = { "astro", "html", "css", "javascript", "typescript" },
        },
      },
    },
  },
}
