--- A module with utilities for tables.
local M = {}

--- Shifts a sequence to the left.
---
---@tparam table t The sequence to shift.
---@treturn table A shifted sequence.
M.shift = function(t)
	local new_t = {}
	for index, value in ipairs(t) do
		if index > 1 then
			new_t[index - 1] = value
		end
	end
	return new_t
end

return M
