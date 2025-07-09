return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()

    -- Color table for highlights
    -- stylua: ignore start
    local colors = {
      bg       = 'None',
      -- bg       = '#282828',
      bglight  = '#504945',
      bgdark   = '#3f3d3f',
      fg       = '#bbc2cf',
      yellow   = '#F0E68C',
      cyan     = '#008080',
      darkblue = '#081633',
      green    = "#37b97e",
      orange   = '#FF8800',
      violet   = '#a9a1e1',
      magenta  = '#c678dd',
      blue     = '#51afef',
      red      = '#ec5f67',
      pink     = '#FF69B4',
      snow     = '#FFFAFA',
      black    = '#000000',
    }

    local mode_color = {
      n       = colors.blue,
      i       = colors.green,
      v       = colors.orange,
      [""]  = colors.orange,
      V       = colors.orange,
      c       = colors.blue,
      no      = colors.red,
      s       = colors.orange,
      S       = colors.orange,
      [""]  = colors.orange,
      ic      = colors.yellow,
      R       = colors.violet,
      Rv      = colors.violet,
      cv      = colors.red,
      ce      = colors.red,
      r       = colors.lyan,
      rm      = colors.cyan,
      ["r?"]  = colors.cyan,
      ["!"]   = colors.red,
      t       = colors.red,
    }
    -- stylua: ignore end

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    -- Config
    local config = {
      options = {
        -- Disable sections and component separators
        component_separators = "",
        -- section_separators = "",
        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statusline
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
        globalstatus = true,
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x at right section
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left({
      function()
        return " "
      end,
      padding = { right = 0 },
    })

    ins_left({
      "mode",
      icon = "",
      -- You should use a function here to make it change color according to mode
      color = function()
        return { bg = mode_color[vim.fn.mode()], fg = colors.black, gui = "bold" }
      end,
      separator = { left = "", right = "" },
      padding = { left = 1, right = 1 },
    })

    ins_left({
      "branch",
      icon = "",
      -- color = { fg = colors.violet, bg = colors.bg, gui = "bold" },
      color = { fg = colors.violet, bg = colors.bg, gui = "bold" },
      cond = conditions.hide_in_width,
    })

    ins_left({
      "filename",
      icon = "",
      color = { bg = colors.bg, gui = "bold" },
    })

    ins_left({
      function()
        return "%="
      end,
      cond = conditions.hide_in_width,
    })

    ins_left({
      -- LSP server name .
      function()
        local msg = "No Active LSP"
        local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
          return msg
        end
        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            return client.name
          end
        end
        return msg
      end,
      icon = "󰨞 ",
      -- icon = "  LSP:",
      color = { fg = colors.blue, gui = "bold" },
      cond = conditions.hide_in_width,
    })

    -- Add components to right sections

    -- ins_right({
    --   "diagnostics",
    --   sources = { "nvim_diagnostic", "coc" },
    --   sections = { "error", "warn", "info", "hint" },
    --   -- symbols = { error = "🤣", warn = "🧐", info = "🫠", hint = "🤔" },
    --   symbols = { error = " ", warn = " ", info = " ", hint = "🤔" },
    --   diagnostics_color = {
    --     error = { fg = colors.red },
    --     warn = { fg = colors.yellow },
    --     info = { fg = colors.cyan },
    --     hint = { fg = colors.blue },
    --   },
    -- })

    ins_right({
      "diff",
      symbols = { added = " ", modified = " ", removed = " " },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
      },
      color = { bg = colors.bg },
      cond = conditions.hide_in_width,
    })

    ins_right({
      "fileformat",
      fmt = string.upper,
      icons_enabled = true, -- I think icons are cool but Eviline doesn't have them. sigh
      color = { fg = colors.blue, bg = colors.bg, gui = "bold" },
      cond = conditions.hide_in_width,
    })

    ins_right({
      "encoding",
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, bg = colors.bg, gui = "bold" },
    })

    ins_right({
      "filetype",
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, bg = colors.bg, gui = "bold" },
    })

    -- ins_right({
    --   function()
    --     return ""
    --   end,
    --   padding = { left = 0, right = 0 },
    --   color = { bg = colors.bg, fg = colors.bglight, gui = "bold" },
    --   cond = conditions.hide_in_width,
    -- })

    ins_right({
      "progress",
      -- icon = { "", align = "right" },
      color = { fg = colors.blue, bg = colors.bg, gui = "bold" },
      cond = conditions.hide_in_width,
    })

    ins_right({
      "location",
      padding = { left = 0, right = 0 },
      color = { fg = colors.blue, bg = colors.bg, gui = "bold" },
    })

    -- Now don't forget to initialize lualine
    require("lualine").setup(config)
  end,
}
