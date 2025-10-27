---Given a predicate, returns a new one that's the negation of the first.
---@param fn fun(...): boolean A predicate to negate
---@return function # A predicate that's the negation of `fn`.
local function negate(fn)
	return function(...)
		return not fn(...)
	end
end

---Checks whether a query `@target` is preceded by a node of a given type.
---E.g. `((identifier) @id (#preceded-by? @id generic_type))`
---Finds a Java method or param with a generic type
---See `:help vim.treesitter.query.add_directive` for more details.
---@param match table<integer, TSNode[]> A table mapping capture ids to a list of nodes
---@param pattern integer Index of the current pattern in the query.
---@param source integer|string Buffer handle of the source text.
---@param predicate table List of strings containing the full predicate, e.g. { "eq?", 1, "value" }
---@return boolean # Whether the predicate matches.
local function preceded_by(match, pattern, source, predicate)
	local target = match[predicate[2]]
	local preceding_type = predicate[3]

	target = target and target[#target]
	if target then
		local prev = target:prev_sibling()
		if prev then
			return prev:type() == preceding_type
		end
	end
	return false
end

local ts_query = require("vim.treesitter.query")
ts_query.add_predicate("preceded-by?", preceded_by, { force = true })
ts_query.add_predicate("not-preceded-by?", negate(preceded_by), { force = true })
