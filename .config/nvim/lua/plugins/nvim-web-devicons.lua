return {
	-- To see all applied icons and highlight groups:
	-- :NvimWebDeviconsHiTest
	"nvim-tree/nvim-web-devicons",
	config = function()
		local devicons = require("nvim-web-devicons")
		devicons.setup({})

		local function override_icons()
			devicons.set_icon({
				java = {
					icon = "", -- \ue26a coffee beans
					color = "#ED8A00",
					name = "Java",
				},
				lua = {
					icon = "", -- \ue620 nf-seti-lua
					color = "#6D8086",
					name = "Lua",
				},
			})
		end

		override_icons()

		-- To guarantee that highlights are applied last at color changes
		-- (sometimes something would reset my :hi DevIconLua)
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("DeviconsAugroup", { clear = true }),
			callback = override_icons,
		})
	end,
}
