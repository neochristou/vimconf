return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "windwp/nvim-ts-autotag",
        },
        config = function()
            require("nvim-treesitter").setup()

            require("nvim-treesitter").install({
                "bash",
                "c",
                "dockerfile",
                "gitignore",
                "json",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "rust",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
            })

            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })

            require("nvim-ts-autotag").setup()
        end,
    },
}
