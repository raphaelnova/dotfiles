vim.opt.ffs = { "unix" }
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fixendofline = false
vim.opt.swapfile = false
vim.opt.modeline = true
vim.opt.showmode = false

-- Disable netrw to use nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.foldenable = true
vim.opt.foldtext = ''       -- enable transparent folds (with syntax hightlight)
vim.opt.foldlevel = 99      -- open all folds by default
vim.opt.foldlevelstart = 99 -- ensure new buffers start unfolded
vim.opt.foldmethod = "expr" -- fold by syntax tree with treesitter (below)
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.fillchars = { fold = " " }

-- Check ftplugins for possible overwrites
vim.opt.tabstop = 2      -- how many columns a \t occupies
vim.opt.shiftwidth = 0   -- columns for each indent level (0 = same as tabstop)
vim.opt.softtabstop = -1 -- columns added by <TAB> or removed by <BS> (neg = same as shiftwidth)
vim.opt.expandtab = true -- insert spaces instead of \t

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorcolumn = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 1
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 20
vim.opt.wrap = true
vim.opt.showbreak = "»»»" -- \u00bb Right-pointing double angle quotation mark
vim.opt.list = true
vim.opt.listchars = {
	space    = "·",  -- \u00B7 Period center
	trail    = "×",  -- \u00d7 Multiplication
	tab      = "›-", -- \u203a Single right-pointing angle quotation mark + hyphen
	precedes = "↢",  -- \u21a2 Leftwards arrow with tail
	extends  = "↣",  -- \u21a3 Rightwards arrow with tail
	nbsp     = "␣",  -- \u2423 Open box
	eol      = "↵",  -- \u21b5 Downwards arrow with corner leftwards
}
vim.opt.winborder = 'single'

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 1000 -- set timeout for mapped sequences
vim.opt.undofile = true   -- enable persistent undo
vim.opt.updatetime = 100  -- set faster completion

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- vim.opt.grepprg = 'rg --vimgrep'
-- vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.showmatch = true -- blink matching pair when closing

