--- Extra string-related utilities.
local M = {}

--- Checks if a string uses only unicase characters.
---
--- A unicase character is a character that is neither upper nor lower case,
--- e.g., punctuation or Japanese kanji.
---
---@param str string the string to check
---@return boolean result whether the string is in unicase
M.is_unicase = function(str)
	return vim.fn.toupper(str) == vim.fn.tolower(str)
end

--- Checks if a char is in upper case.
---
---@param char string the char to check
---@return boolean result whether the char is in upper case
M.is_upper = function(char)
	return not M.is_unicase(char) and vim.fn.toupper(char) == char
end

--- Checks if a char is in lower case.
---
---@param char string the char to check
---@return boolean result whether the char is in lower case
M.is_lower = function(char)
	return not M.is_unicase(char) and not M.is_upper(char)
end

--- Splits a string into a list of Unicode graphemes.
---
--- Includes combining characters into a single grapheme.
---
--- See also vim.fn.str2list, which splits a string into a list of code points.
---
---@param str string the string to split
---@return string[] charlist list of characters
M.str2graphemelist = function(str)
	local charlist = {}
	local stridx = 0
	while stridx < string.len(str) do
		local current_charidx = vim.fn.charidx(str, stridx)
		local charend = 1
		while stridx + charend < string.len(str) do
			local next_charidx = vim.fn.charidx(str, stridx + charend)
			if current_charidx ~= next_charidx then
				break
			end
			charend = charend + 1
		end
		table.insert(charlist, string.sub(str, stridx + 1, stridx + charend))
		stridx = stridx + charend
	end
	return charlist
end

return M
