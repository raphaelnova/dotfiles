return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load({})
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			---@type table<string, string> Defines icons for the cmp menu
			local kind_icons = {
				Class = "", -- 󰆦
				Color = "󰏘",
				Constant = "󰏿",
				Constructor = "󰒓",
				Enum = "",
				EnumMember = "󱡠", -- 
				Event = "", -- 󱐋
				Field = "", -- 󰇽
				File = "󰈙",
				Folder = "󰉋",
				Function = "󰊕",
				Interface = "",
				Keyword = "󰌋",
				Method = "󰆧",
				Module = "󰅩",
				Operator = "󰆕",
				Property = "󱕂", -- 󰜢
				Reference = "󰬲", -- 
				Snippet = "", --  󰅪 
				Struct = "", -- 
				Text = "󰦨",
				TypeParameter = "", -- 󰅲
				Unit = "",
				Value = "󰎠",
				Variable = "󰂡",
			}

			vim.opt.completeopt = "menu,menuone,preview,noinsert"

			cmp.setup({
				formatting = {
					format = function (entry, vim_item)
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[LuaSnip]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]

						return vim_item
					end,
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = require("config.keymaps").cmp(),
				sources = cmp.config.sources({
					{
						name = "nvim_lsp",
						option = {
							markdown_oxide = {
								keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
							},
						},
					},
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
}
