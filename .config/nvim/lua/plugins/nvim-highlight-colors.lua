return {
	"brenoprata10/nvim-highlight-colors",
	config = function()
		vim.opt.termguicolors = true

		require("nvim-highlight-colors").setup({
			render = "virtual",
			virtual_symbol = "●",
			virtual_symbol_position = "eol",
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = true,
			enable_ansi = true,
			enable_hsl_without_function = true,
			enable_var_usage = true,
		})
	end,
}
