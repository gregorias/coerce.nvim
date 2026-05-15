--- A module for interactively getting input.
local M = {}

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
	return vim.keycode(char)
end

return M
