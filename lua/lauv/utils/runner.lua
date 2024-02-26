function _G._my_wrapper_run_in_terminal(mytable)
    mytable.cmd = mytable.cmd or vim.fn.input("Enter command: ")
    mytable = vim.tbl_deep_extend("force", { hidden = true }, mytable)
    require("toggleterm.terminal").Terminal:new(mytable):toggle()
    -- require("toggleterm").exec(mytable.cmd)
end

local function cmr()
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
    local run_target = ("%s/%s"):format(build_dir, build_target)

    local cmd = ""

    if file_name and file_type then
        if file_type == "python" then
            cmd = ("python %s"):format(file_name)
        elseif file_type == "c" or file_type == "cpp" then
            if os.execute("test -e " .. cmk) == 0 then
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
                local build = "run_" .. build_target
                cmd = ("g++ %s -o %s %s && ./%s"):format(option, build, file_name, build)
            end
        elseif file_type == "java" then
            cmd = "javac " .. file_name .. ".java"
            cmd = "java " .. file_name
        elseif file_type == "markdown" then
            vim.api.nvim_command("MarkdownPreview")
        elseif file_type == "typst" then
            vim.api.nvim_command("TypstWatch")
        end
    end
    if cmd == "" then
        return
    end
    _G._my_wrapper_run_in_terminal({ cmd = cmd, close_on_exit = false })
end

local function run()
    local cmd = 'build/main'
    _G._my_wrapper_run_in_terminal({ cmd = cmd, close_on_exit = false })
end
vim.keymap.set("n", "<F5>", cmr, { silent = true })
vim.keymap.set("n", "<F6>", run, { silent = true })
