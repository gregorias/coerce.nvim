--- A module for case conversion.
-- @module coerce.case
local M = {}

--- Converts a string into a numerical contraction.
--
--@param str The string to convert.
--@return The numerical contraction.
M.to_numerical_contraction = function(str)
	local cs = require("coerce.string")

	local grapheme_list = cs.str2graphemelist(str)
	if #grapheme_list <= 2 then
		return str
	end

	local character_count = 0
	local idx = 2
	while idx <= (#grapheme_list - 1) do
		local grapheme = grapheme_list[idx]
		if vim.fn.charclass(grapheme) == 2 then
			character_count = character_count + 1
		end
		idx = idx + 1
	end

	return grapheme_list[1] .. character_count .. grapheme_list[#grapheme_list]
end

return M
