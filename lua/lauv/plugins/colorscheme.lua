return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true,
    styles = {
      -- sidebars = "transparent",
      floats = "transparent",
    },
  },
  init = function()
    vim.cmd.colorscheme("tokyonight")
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { link = "StatusLine" })
    vim.api.nvim_set_hl(0, "StatusLineTerm", { link = "StatusLine" })
    vim.api.nvim_set_hl(0, "StatusLineTermNC", { link = "StatusLine" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })

    vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#878787" })

    -- vim.api.nvim_set_hl(0, "VirtualTextHint", { link = "DiagnosticHint" })
    -- vim.api.nvim_set_hl(0, "VirtualTextInfo", { link = "DiagnosticInfo" })
    -- vim.api.nvim_set_hl(0, "VirtualTextWarning", { link = "DiagnosticWarn" })
    -- vim.api.nvim_set_hl(0, "VirtualTextError", { link = "DiagnosticError" })

    vim.api.nvim_set_hl(0, "BlinkCmpSource", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
  end,
}
