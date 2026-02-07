-- Only show Markdown formatting syntax under the cursor
vim.opt.conceallevel = 2

-- Works on vim with gq, but not here due to 'formatexpr'
-- Has something to do with none-ls and prettier, which load
-- as an LSP for markdown files.
vim.opt.textwidth = 100
-- vim.opt.formatoptions += ...
