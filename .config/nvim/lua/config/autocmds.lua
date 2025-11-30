local buffer_group = vim.api.nvim_create_augroup("buf_cmds", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*",
	group = buffer_group,
	desc = "Disables native highlight color (I prefer using a plugin).",
	callback = function()
		vim.lsp.document_color.enable(false)
		-- vim.lsp.document_color.enable(true, 0, { style = 'virtual' })
	end
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "lua/config/*.lua",
	group = buffer_group,
	desc = "Hot-reloads any changed Lua module.",
	callback = function(args)
		local module_name = (vim.loop.cwd() .. "/" .. args.file)
			 :gsub("^" .. vim.fn.stdpath("config") .. "/lua/", "")
			 :gsub("%.lua$", "")
			 :gsub("/", ".")
			 :gsub("%.init$", "")
		package.loaded[module_name] = nil
		require(module_name)
	end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
	pattern = "*",
	group = buffer_group,
	desc = "Disables relative line numbers when in Insert mode.",
	callback = function(autocmd)
		vim.opt.relativenumber = (autocmd.event == "InsertLeave")
	end,
})

--
-- Dynamic highlight for trailing spaces (only when out of insert mode).
--
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	group = buffer_group,
	desc = "Matches trailing spaces and creates a highlight group for them.",
	callback = function()
		vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = buffer_group,
	desc = "Disables trailing space highlighting when in Insert mode.",
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	group = buffer_group,
	desc = "Enables trailing spaces highlighting when out of Insert mode.",
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "TrailingWhitespaceStyle" })
	end,
})
