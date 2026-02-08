return {
	{
		"nvim-telescope/telescope.nvim",
		-- tag = "*",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Replaces vim.ui.select with a Telescope UI. To see it in action:
			-- := vim.ui.select({"a", "b", "c"}, {}, function(choice) print(choice) end)
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local keymaps = require("config.keymaps")

			telescope.setup({
				pickers = {
					find_files = {
						layout_config = {
							prompt_position = "top",
							preview_cutoff = 9999, -- disable previewer
						},
						sorting_strategy = "ascending",
					},
					buffers = {
						mappings = {
							n = {
								["d"] = require("telescope.actions").delete_buffer,
							}
						}
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					mappings = {
						i = {
							["<C-n>"] = "cycle_history_next",
							["<C-p>"] = "cycle_history_prev",
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
						},
					},
				},
			})

			telescope.load_extension("ui-select")
			keymaps.telescope()
		end,
	},
}
