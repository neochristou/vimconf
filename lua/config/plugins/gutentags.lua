return {
    "ludovicchabant/vim-gutentags",
    config = function()
        if vim.fn.executable("fd") == 0 then
            return function() end
        end

        if vim.fn.executable("ctags") == 0 then
            return function() end
        end

        vim.g.gutentags_ctags_executable = "/opt/homebrew/bin/ctags"
        vim.g.gutentags_define_advanced_commands = true
        vim.g.gutentags_file_list_command = "fd --strip-cwd-prefix"
    end,
}
