return {
	"nvim-tree/nvim-web-devicons",
	config = function()
		-- To see all applied icons and highlight groups:
		-- :NvimWebDeviconsHiTest
		require("nvim-web-devicons").setup({
			override = {
				java = {
					icon = "", -- \ue26a coffee beans + extra space because it's not monospaced
					color = "#ED8A00",
					name = "Java",
				},
				lua = {
					icon = "",
					color = "#6D8086",
					name = "Lua",
				},
			},
		})
	end,
}
