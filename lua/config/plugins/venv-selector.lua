return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	lazy = false,
	config = function()
		require("venv-selector").setup()
	end,
	keys = {
		{ ",v", "<cmd>VenvSelect<cr>" },
	},
}
