local python = require("lang.python")
if not vim.g.session_state["lang.python.setup_tools"] then
	vim.g.session_state["lang.python.setup_tools"] = true
	python.setup_tools()
end
python.setup_buffer(vim.api.nvim_get_current_buf())
