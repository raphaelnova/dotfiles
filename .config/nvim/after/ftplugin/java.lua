-- This setups JDTLS, but I'm using nvim-java now.
-- require("lang.java").setup_buffer(vim.api.nvim_get_current_buf())

local bufnr = vim.api.nvim_get_current_buf()
vim.bo[bufnr].tabstop = 4
require("config.keymaps").java(bufnr)
