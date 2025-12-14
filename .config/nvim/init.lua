local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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

-- Data, flags or toggles I need to keep track of during session such
-- as LSP setup info or "has it run yet" flags. Use module names as
-- namespaces to avoid conflicts.
vim.g.session_state = {}

require("config.filetypes")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.folds")
require("config.treesitter.predicates")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✖", -- \u2716 - Heavy Multiplication X
			[vim.diagnostic.severity.WARN]  = "▲", -- \u25b2 - Black up-pointing triangle
			[vim.diagnostic.severity.INFO]  = "⚑", -- \u2691 - Black flag
			[vim.diagnostic.severity.HINT]  = "✚", -- \u271a - Heavy greek cross
		},
	},
})

vim.cmd("packadd nvim.undotree")

-- Always last. "plugins" mean folder ./lua/plugins
require("lazy").setup("plugins", {
	change_detection = {
		notify = false, -- # Config change detected. Reloading...
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
