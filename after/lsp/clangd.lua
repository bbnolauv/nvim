local BUILD_CONFIG = {
  cache_timeout = 600, -- 10 minutes
  cmake_build_dir = 'build',
}

local function has_cmakelists(root_dir)
  if not root_dir then
    return false
  end
  return vim.uv.fs_stat(vim.fs.joinpath(root_dir, 'CMakeLists.txt')) ~= nil
end

local function clangd_notify(msg, level)
  return vim.notify(msg, level, { title = 'Clangd' })
end
-- Check if compile_commands.json needs to be generated based on age/existence.
local function should_generate_commands(root_dir, CONFIG)
  if not root_dir then
    return false
  end

  local now = os.time()
  local candidates = {
    vim.fs.joinpath(root_dir, 'compile_commands.json'),
    vim.fs.joinpath(root_dir, CONFIG.cmake_build_dir, 'compile_commands.json'),
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
    clangd_notify('CMakeLists.txt not found, skipping generation', vim.log.levels.WARN)
  end

  if vim.fn.executable('cmake') ~= 1 then
    clangd_notify('CMake executable not found, skipping generation', vim.log.levels.WARN)
  end

  clangd_notify('Generating compilation database...', vim.log.levels.INFO)
  require('cmake-tools').generate({}, function(result)
    if result:is_ok() then
      clangd_notify('Compilation database generated.', vim.log.levels.INFO)
    else
      clangd_notify('CMake generation failed.', vim.log.levels.ERROR)
    end
  end)
end

---@type vim.lsp.Config
return {
  on_init = function(client, _)
    local root_dir = client.config.root_dir
    if should_generate_commands(root_dir, BUILD_CONFIG) then
      vim.schedule(function()
        generate_compile_commands(root_dir)
      end)
    end
  end,
  on_attach = function(client, bufnr)
    if has_cmakelists(client.config.root_dir) then
      -- Replace the command originally mapped to <F5> from runner.lua with the cmake-tools command.
      vim.keymap.set(
        'n',
        '<F5>',
        '<cmd>CMakeRun<cr>',
        { buffer = bufnr, silent = true, desc = 'Run CMake Target' }
      )
    end
  end,
}
