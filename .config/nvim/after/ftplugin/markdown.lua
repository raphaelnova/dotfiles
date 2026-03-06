-- Only show Markdown formatting syntax under the cursor
vim.opt.conceallevel = 0

require("lang.markdown").setup_buffer(vim.api.nvim_get_current_buf())
