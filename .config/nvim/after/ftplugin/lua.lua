local lua = require("lang.lua")
if not vim.g.session_state["lang.lua.setup_tools"] then
	vim.g.session_state["lang.lua.setup_tools"] = true
	lua.setup_tools()
end
lua.setup_buffer(vim.api.nvim_get_current_buf())
