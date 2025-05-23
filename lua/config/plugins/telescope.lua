return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local file_ignore_patterns = {
            "yarn%.lock",
            "node_modules/",
            "dist/",
            "%.next",
            "build/",
            "target/",
            "package%-lock%.json",
            "%.o",
            "%.d",
        }

        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                file_ignore_patterns = file_ignore_patterns,
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next, -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })

        telescope.load_extension("fzf")
    end,
}
