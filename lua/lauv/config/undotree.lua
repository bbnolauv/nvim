return {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    config = function()
        vim.cmd([[
        if has("persistent_undo")
       let target_path = expand('/tmp/undodir')

        " create the directory and any parent directories
        " if the location does not exist.
        if !isdirectory(target_path)
            call mkdir(target_path, "p", 0700)
        endif

        let &undodir=target_path
        set undofile
        endif
        ]])
    end


}
