return {
  "Civitasv/cmake-tools.nvim",
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  init = function()
    local loaded = false
    local function check()
      local cwd = vim.uv.cwd()
      if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
        require("lazy").load({ plugins = { "cmake-tools.nvim" } })
        loaded = true
      end
    end
    check()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        if not loaded then
          check()
        end
      end,
    })
  end,
  opts = {
    cmake_generate_options = { "-GNinja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }, -- this will be passed when invoke `CMakeGenerate`
    cmake_build_directory = "build",
    -- cmake_soft_link_compile_commands = false,

    cmake_executor = {
      name = "quickfix",
      opts = {
        position = "botright",
        show = "only_on_error",
      },
    },
    cmake_runner = {
      name = "toggleterm",
      opts = {
        direction = "vertical",
        close_on_exit = false,
        auto_scroll = true,
        singleton = true,
      },
    },
    cmake_notifications = {
      runner = { enabled = true },
      executor = { enabled = true },
      spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
      refresh_rate_ms = 100, -- how often to iterate icons
    },
    cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
  },
}
