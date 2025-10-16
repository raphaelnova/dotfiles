return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		vim.keymap.set("n", "<leader>\\", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment line." })
		vim.keymap.set("v", "<leader>\\", "<Plug>(comment_toggle_linewise_visual)", { desc = "Comment selected." })

		require("Comment").setup({
			prehook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
	end,
}
