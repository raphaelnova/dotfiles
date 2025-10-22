return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local extensions = require("harpoon.extensions").builtins

		harpoon:setup()
		harpoon:extend(extensions.highlight_current_file())
		harpoon:extend(extensions.navigate_with_number())

		require("config.keymaps").harpoon()
	end,
}
