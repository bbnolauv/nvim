function _G._my_wrapper_run_in_terminal(mytable)
  mytable.cmd = mytable.cmd or vim.fn.input("Enter command: ")
  mytable = vim.tbl_deep_extend("force", { hidden = true }, mytable)
  require("toggleterm.terminal").Terminal:new(mytable):toggle()
  -- require("toggleterm").exec(mytable.cmd)
end

local function match()
  -- Simulating reading content from a file
  local CMAKELISTS_CONTENT = io.open("CMakeLists.txt", "r"):read("*a")

  -- Simulating string regex match
  local TARGET_NAME = string.match(CMAKELISTS_CONTENT, "add_executable%(([^%s]+)")

  return TARGET_NAME
end

-- [FOR DEBUG]
-- Get back the output of os.execute in Lua
function os.capture(cmd, raw)
  local handle = assert(io.popen(cmd, "r"))
  local output = assert(handle:read("*a"))

  handle:close()

  if raw then
    return output
  end

  output = string.gsub(string.gsub(string.gsub(output, "^%s+", ""), "%s+$", ""), "[\n\r]+", " ")

  return output
end

local function build_and_run()
  vim.api.nvim_command("write")
  local build_dir = "build"
  local build_gen = "Ninja"
  local cmk = "CMakeLists.txt"

  local file_name = vim.fn.expand("%:t")
  local file_type = vim.bo.filetype
  local file_path = vim.fn.expand("%:p:h")
  local fileNameWithoutExt = vim.fn.expand("%:t:r")

  local option = ""
  -- option = "-std=c++20"
  local build_target = fileNameWithoutExt

  local cmd = ""

  if file_name and file_type then
    if file_type == "python" then
      cmd = ("python %s"):format(file_name)
    elseif file_type == "c" or file_type == "cpp" then
      if os.execute("test -e " .. cmk) == 0 then
        build_target = match()
        local run_target = ("%s/%s"):format(build_dir, build_target)
        if os.execute("test -d " .. build_dir) ~= 0 then
          cmd = ("cmake -S %s -B %s -G %s -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON &&"):format(
            file_path,
            build_dir,
            build_gen
          )
        end
        cmd = cmd .. ("cmake --build %s --target %s &&"):format(build_dir, build_target)
        cmd = cmd .. run_target
      else
        local run_target = "run_" .. build_target
        cmd = ("g++ %s -o /tmp/%s %s && /tmp/%s"):format(option, run_target, file_name, run_target)
      end
    elseif file_type == "markdown" then
      vim.api.nvim_command("MarkdownPreview")
      return
    elseif file_type == "yacc" then
      cmd = "bison  " .. file_name
      -- elseif file_type == "java" then
      --     cmd = "javac " .. file_name
      --     cmd = "java " .. file_name
      -- elseif file_type == "typst" then
      --     vim.api.nvim_command("TypstWatch")
    end
  end
  if cmd == "" then
    error("No matched file format found! ")
  end
  _G._my_wrapper_run_in_terminal({ cmd = cmd, close_on_exit = false })
end

local function run()
  local cmd = "build/"
  local build_target = match()
  cmd = cmd .. build_target
  _G._my_wrapper_run_in_terminal({ cmd = cmd, close_on_exit = false })
end
vim.keymap.set("n", "<F5>", build_and_run, { silent = true })
vim.keymap.set("n", "<F6>", run, { silent = true })
