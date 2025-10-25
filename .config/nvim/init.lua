local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- vim.fn.stdpath("data") => ~/.local/share/nvim

-- Check whether Lazy has been cloned, and clone it otherwise.
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- :help 'runtimepath'
vim.opt.rtp:prepend(lazypath)

require("config.filetypes")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.folds")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✘",
			[vim.diagnostic.severity.WARN]  = "▲",
			[vim.diagnostic.severity.HINT]  = "⚑",
			[vim.diagnostic.severity.INFO]  = "»",
		},
	},
})

-- Always last. "plugins" mean folder ./lua/plugins
require("lazy").setup("plugins", {
	change_detection = {
		notify = false, -- # Config change detected. Reloading...
	},
	checker = {
		enable = true,  -- Auto check for updates
		notify = true,  -- Update notifications
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrw",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
