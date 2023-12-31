--- Extra string-related utilities.
-- @module coerce.string
local M = {}

--- Checks if a string uses only unicase characters.
--
-- A unicase character is a character that is neither upper nor lower case,
-- e.g., punctuation or Japanese kanji.
--
--@param str The string to check.
--@return True iff the string is in unicase.
M.is_unicase = function(str)
	return vim.fn.toupper(str) == vim.fn.tolower(str)
end

--- Checks if a char is in upper case.
--
--@param char The char to check.
--@return True iff the char is in upper case.
M.is_upper = function(char)
	return not M.is_unicase(char) and vim.fn.toupper(char) == char
end

--- Checks if a char is in lower case.
--
--@param char The char to check.
--@return True iff the char is in lower case.
M.is_lower = function(char)
	return not M.is_unicase(char) and not M.is_upper(char)
end

return M
