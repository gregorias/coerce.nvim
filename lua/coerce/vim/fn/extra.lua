--- Extra vim.fn utilities.
local M = {}

--- Gets the specified position.
--
-- If expr is invalid, returns nil.
--
--@tparam expr
--@treturn table A 2-tuple containing the line and column. Zero-indexed.
M.getpos = function(expr)
	local pos = vim.fn.getpos(expr)

	if pos[1] == 0 and pos[2] == 0 and pos[3] == 0 and pos[4] == 0 then
		-- We are not reporting nil in the type signature. It’s a programmer error,
		-- so we don’t need to ask the programmer to handle it.
		return nil
	end

	return { pos[2] - 1, pos[3] - 1 }
end

return M
