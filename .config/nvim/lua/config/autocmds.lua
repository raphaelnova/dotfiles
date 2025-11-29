local buffer_group = vim.api.nvim_create_augroup("buf_cmds", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*",
	callback = function()
		vim.lsp.document_color.enable(false)
		-- vim.lsp.document_color.enable(true, 0, { style = 'virtual' })
	end
})

-- Config module hot-reload
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "lua/config/*.lua",
	group = buffer_group,
	callback = function(args)
		local module_name = (vim.loop.cwd() .. "/" .. args.file)
			 :gsub("^" .. vim.fn.stdpath("config") .. "/lua/", "")
			 :gsub("%.lua$", "")
			 :gsub("/", ".")
			 :gsub("%.init$", "")
		package.loaded[module_name] = nil
		require(module_name)
		-- vim.notify("Reloaded " .. module_name, vim.log.levels.INFO)
	end,
})

-- disable relative line numbers on insert mode
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
	pattern = "*",
	group = buffer_group,
	callback = function(autocmd)
		vim.opt.relativenumber = (autocmd.event == "InsertLeave")
	end,
})

--
-- Highlight trailing spaces only out of insert mode
--
vim.api.nvim_create_autocmd("BufWinEnter", {
	-- Match trailing spaces and highlight them
	callback = function()
		vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	-- Disable trailing spaces highilighting when in Insert mode
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	-- Enable trailing spaces highilighting when out of Insert mode
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "TrailingWhitespaceStyle" })
	end,
})
