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

local BUILD_CONFIG = {
  cache_timeout = 600, -- 10 minutes
  cmake_build_dir = "build",
}

local function has_cmakelists(root_dir)
  if not root_dir then
    return false
  end
  return vim.uv.fs_stat(vim.fs.joinpath(root_dir, "CMakeLists.txt")) ~= nil
end

-- Check if compile_commands.json needs to be generated based on age/existence.
local function should_generate_commands(root_dir, CONFIG)
  if not root_dir then
    return false
  end

  local now = os.time()
  local candidates = {
    vim.fs.joinpath(root_dir, "compile_commands.json"),
    vim.fs.joinpath(root_dir, CONFIG.cmake_build_dir, "compile_commands.json"),
  }

  for _, path in ipairs(candidates) do
    local file_stat = vim.uv.fs_stat(path)
    if file_stat and (now - file_stat.mtime.sec) < CONFIG.cache_timeout then
      return false
    end
  end

  return true
end

-- Core logic to generate compile_commands.json using cmake-tools
local function generate_compile_commands(root_dir)
  if not has_cmakelists(root_dir) then
    return vim.notify("CMakeLists.txt not found, skipping generation", vim.log.levels.WARN)
  end

  if vim.fn.executable("cmake") ~= 1 then
    return vim.notify("CMake executable not found, skipping generation", vim.log.levels.WARN)
  end

  local ok, cmake_tools = pcall(require, "cmake-tools")
  if not ok then
    return vim.notify("cmake-tools.nvim not found, skipping generation", vim.log.levels.WARN)
  end

  vim.notify("[LSP] Generating compilation database...", vim.log.levels.INFO)
  --- @diagnostic disable-next-line: need-check-nil
  cmake_tools.generate({}, function(result)
    if result:is_ok() then
      vim.notify("[LSP] Compilation database generated.", vim.log.levels.INFO)
    else
      vim.notify("[LSP] CMake generation failed.", vim.log.levels.ERROR)
    end
  end)
end

-- Prepare Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-8", "utf-16" }

---@class ClangdInitializeResult: lsp.InitializeResult
---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--pch-storage=memory",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "CMakeLists.txt",
    ".git",
  },
  capabilities = capabilities,

  ---@param client vim.lsp.Client
  ---@param _init_result ClangdInitializeResult
  on_init = function(client, _init_result)
    local root_dir = client.config.root_dir

    if should_generate_commands(root_dir, BUILD_CONFIG) then
      vim.schedule(function()
        generate_compile_commands(root_dir)
      end)
    end
  end,

  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr)
    -- Function to switch between source file and header
    local function switch_source_header()
      local method_name = "textDocument/switchSourceHeader"
      if not client:supports_method(method_name) then
        return vim.notify(("Method %s is not supported by current server"):format(method_name), vim.log.levels.WARN)
      end

      local params = vim.lsp.util.make_text_document_params(bufnr)
      client:request(method_name, params, function(err, result)
        if err then
          return vim.notify("Error switching source/header: " .. tostring(err), vim.log.levels.ERROR)
        end
        if not result then
          return vim.notify("Corresponding file cannot be determined", vim.log.levels.INFO)
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end, bufnr)
    end

    -- Function to show symbol info
    local function symbol_info()
      local method_name = "textDocument/symbolInfo"
      if not client:supports_method(method_name) then
        return vim.notify("Clangd client not found or doesn't support symbolInfo", vim.log.levels.ERROR)
      end

      local params = vim.lsp.util.make_position_params(0, client.offset_encoding) -- 0 for current win
      client:request(method_name, params, function(err, res)
        if err or not res or #res == 0 then
          return vim.notify("No symbol info available", vim.log.levels.INFO)
        end

        local container = string.format("container: %s", res[1].containerName or "global")
        local name = string.format("name: %s", res[1].name)

        vim.lsp.util.open_floating_preview({ name, container }, "markdown", {
          focusable = false,
          focus = false,
          title = "Symbol Info",
        })
      end, bufnr)
    end

    -- Create User Commands
    vim.api.nvim_buf_create_user_command(bufnr, "ClangdSwitchSourceHeader", function()
      switch_source_header()
    end, { desc = "Switch between source/header" })

    vim.api.nvim_buf_create_user_command(bufnr, "ClangdShowSymbolInfo", function()
      symbol_info()
    end, { desc = "Show symbol info" })

    if has_cmakelists(client.config.root_dir) then
      -- Replace the command originally mapped to <F5> from runner.lua with the cmake-tools command.
      vim.keymap.set("n", "<F5>", "<cmd>CMakeRun<cr>", { buffer = bufnr, silent = true, desc = "Run CMake Target" })
    end
  end,
}
