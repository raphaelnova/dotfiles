return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		expand = 1,
		preset = "helix",
		icons = {
			breadcrumb = "",
			separator = "│",
			group = "+ ",
			mappings = false, -- false to disable icons
		},
		spec = {
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Debug" }, -- icon = { icon = "# ", hl = "TrailingWhitespaceStyle" }
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>J", group = "Java actions" },
			{ "<leader>s", group = "Shell" },
			{ "<leader>w", group = "Window" },
		},
	},
	plugins = {
		marks = false,
		registers = false,
		spelling = { enabled = false },
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
