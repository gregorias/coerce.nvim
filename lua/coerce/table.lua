--- A module with utilities for tables.
local M = {}

--- Shifts a sequence to the left.
---
---@param t table The sequence to shift.
---@return table A shifted sequence.
M.shift = function(t)
	local new_t = {}
	for index, value in ipairs(t) do
		if index > 1 then
			new_t[index - 1] = value
		end
	end
	return new_t
end

--- Merges table entries into a single table.
---
--- - Last entry wins.
--- - If there are no arguments, returns an empty table.
--- - Must be provided tables as arguments, not nils.
---
---@param ... ... the tables
---@return table merged_table
M.shallow_merge = function(...)
	local merged_table = {}
	for _, t in ipairs({ ... }) do
		for k, v in pairs(t) do
			merged_table[k] = v
		end
	end
	return merged_table
end

return M
