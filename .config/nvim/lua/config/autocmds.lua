local buffer_group = vim.api.nvim_create_augroup("buf_cmds", { clear = true })

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

