return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    ft = { "lua" },
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = {
        -- "lua_ls",
        -- "pyright",
        -- "cmake",
        -- "clangd",
      },
      automatic_installation = true,
    },
  },
}
