--- A module for working with Neovim's visual mode.
local M = {}

--- An enum representing the different visual modes.
M.visual_mode = {
	INLINE = "inline",
	LINE = "line",
	BLOCK = "block",
}

--- Returns the current visual mode.
--
--@treturn visual_mode The current visual mode.
M.get_current_visual_mode = function()
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" then
		return M.visual_mode.INLINE
	elseif mode == "V" then
		return M.visual_mode.LINE
	elseif mode == "\22" then
		return M.visual_mode.BLOCK
	else
		return nil
	end
end

return M
