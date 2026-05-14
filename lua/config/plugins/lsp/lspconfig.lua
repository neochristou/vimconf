return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- apply capabilities to all servers
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- server-specific configs
		vim.lsp.config("html", {})

		vim.lsp.config("cssls", {})

		vim.lsp.config("tailwindcss", {})

		vim.lsp.config("svelte", {})

		vim.lsp.config("prismals", {})

		vim.lsp.config("emmet_ls", {
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		})

		vim.lsp.config("pyright", {})

		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
					configurationSources = { "flake8", "mypy" },
					plugins = {
						pycodestyle = { enabled = false },
						flake8 = { enabled = false },
					},
				},
			},
		})

		vim.lsp.config("nim_langserver", {
			settings = {
				nim = {
					nimsuggestPath = "~/.nimble/bin/",
				},
			},
		})

		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--completion-style=detailed",
				"--header-insertion=never",
			},
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		-- enable all servers
		vim.lsp.enable({
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"prismals",
			"emmet_ls",
			"pyright",
			"pylsp",
			"nim_langserver",
			"clangd",
			"lua_ls",
		})

		-- global LSP keybindings via LspAttach
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				local opts = { buffer = bufnr, noremap = true, silent = true }

				opts.desc = "Show LSP references"
				vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				vim.keymap.set("n", "gb", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)

				opts.desc = "Go to next diagnostic"
				vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})
	end,
}
