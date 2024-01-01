--- A module for case conversion.
-- @module coerce.case
local M = {}

--- Converts a string into a numeronym.
--
--@param str The string to convert.
--@return The numeronym.
M.to_numeronym = function(str)
	local cs = require("coerce.string")

	local grapheme_list = cs.str2graphemelist(str)
	if #grapheme_list <= 2 then
		return str
	end

	return grapheme_list[1] .. tostring(#grapheme_list - 2) .. grapheme_list[#grapheme_list]
end

return M
