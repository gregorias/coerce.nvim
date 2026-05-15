--- A module for interactively getting input.
local M = {}

---Replaces terminal keycodes in an input character.
---
---@param char string @The input characters.
---@return string @The formatted characters.
---@nodiscard
M.replace_termcodes = function(char)
	-- Do nothing to ASCII or UTF-8 characters
	if #char == 1 or char:byte() >= 0x80 then
		return char
	end
	-- Otherwise assume the string is a terminal keycode.
	return require("coerce.vim.api").replace_all_termcodes(char)
end

---Gets a character input from the user.
---
---@return string? @The input character, or nil if an escape character is pressed.
---@nodiscard
M.get_char = function()
	local ok, char = pcall(vim.fn.getcharstr)
	-- Return nil if input is cancelled (e.g., <C-c> or <Esc>).
	if not ok or char == "\27" then
		return nil
	end
	return M.replace_termcodes(char)
end

return M
