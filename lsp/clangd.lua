-- Ref: https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua

---@brief
---
--- https://clangd.llvm.org/installation.html
---
--- - **NOTE:** Clang >= 11 is recommended! See [#23](https://github.com/neovim/nvim-lspconfig/issues/23).
--- - If `compile_commands.json` lives in a build directory, you should
---   symlink it to the root of your source tree.
---   ```
---   ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
---   ```
--- - clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
---   specified as compile_commands.json, see https://clangd.llvm.org/installation#compile_commandsjson

-- NOTES:
-- Clangd requires compile_commands.json to work and the easiest way to generate it is to use CMake.
-- How to use clangd C/C++ LSP in any project: https://gist.github.com/Strus/042a92a00070a943053006bf46912ae9

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
  local method_name = "textDocument/switchSourceHeader"
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify("corresponding file cannot be determined")
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = "textDocument/symbolInfo"
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify("Clangd client not found", vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format("container: %s", res[1].containerName) ---@type string
    local name = string.format("name: %s", res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

local path = require("plenary.path")
-- Check if compile_commands.json needs to be generated.
local function should_generate_commands(root_dir, CONFIG)
  -- Prioritize checking for compile_commands.json in the project root.
  local root_compile_path = path:new(root_dir, "compile_commands.json")
  if root_compile_path:exists() then
    local file_stat = vim.uv.fs_stat(root_compile_path.filename)
    if file_stat then
      return (os.time() - file_stat.mtime.sec) > CONFIG.cache_timeout
    end
  end
  -- Check for compile_commands.json in the build directory.
  local build_compile_path = path:new(root_dir, CONFIG.cmake_build_dir, "compile_commands.json")
  if build_compile_path:exists() then
    local file_stat = vim.uv.fs_stat(build_compile_path.filename)
    if file_stat then
      return (os.time() - file_stat.mtime.sec) > CONFIG.cache_timeout
    end
  end
  -- If the file doesn't exist in either location, it needs to be generated.
  return true
end

-- Core logic to generate compile_commands.json.
local function generate_compile_commands(root_dir)
  if vim.fn.executable("cmake") == 1 and path:new(root_dir, "CMakeLists.txt"):exists() then
    vim.notify("[LSP] Generating compilation database...", vim.log.levels.INFO)
    require("cmake-tools").generate({}, function(result)
      if result:is_ok() then
        vim.notify("[LSP] Compilation database successfully generated.", vim.log.levels.INFO)
        vim.schedule(function()
          -- Restart LSP asynchronously to load the new file.
          vim.lsp.enable("clangd", false)
          vim.lsp.enable("clangd", true)
        end)
      else
        vim.notify("[LSP] CMake database generation failed.", vim.log.levels.ERROR)
      end
    end)
  else
    vim.notify("[LSP] CMake not found or no CMakeLists.txt. Skipping automatic generation.", vim.log.levels.WARN)
  end
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=none",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
    ".git",
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  ---@param client vim.lsp.Client
  ---@param init_result ClangdInitializeResult
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end

    local m_root_dir = client.config.root_dir or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    local BUILD_CONFIG = {
      cache_timeout = 600,
      cmake_build_dir = "build",
    }
    -- Check for the presence of a project build file, such as CMakeLists.txt.
    local has_cmake_file = path:new(m_root_dir, "CMakeLists.txt"):exists()

    -- If no build file is found, assume it's a single-file setup and exit.
    if not has_cmake_file then
      vim.notify("No CMakeLists.txt found, skipping compilation database generation.", vim.log.levels.INFO)
      return
    end

    -- Replace the command originally mapped to <F5> from runner.lua with the cmake-tools command.
    vim.keymap.set("n", "<F5>", "<cmd>CMakeRun<cr>", { silent = true })

    -- Now, proceed with the logic to check if compile_commands.json needs to be generated.
    if should_generate_commands(m_root_dir, BUILD_CONFIG) then
      vim.schedule(function()
        generate_compile_commands(m_root_dir)
      end)
    end
  end,
  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr)
    -- Create a command to switch between source file and header
    -- https://clangd.llvm.org/extensions.html#switch-between-sourceheader

    vim.api.nvim_buf_create_user_command(bufnr, "ClangdSwitchSourceHeader", function()
      switch_source_header(bufnr, client)
    end, { desc = "Switch between the main source file (*.cpp) and header (*.h)" })

    vim.api.nvim_buf_create_user_command(bufnr, "ClangdShowSymbolInfo", function()
      symbol_info(bufnr, client)
    end, { desc = "Show symbol info" })
  end,
}
