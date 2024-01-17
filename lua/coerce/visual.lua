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
M.get_visual_mode = function()
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

--- Returns the current visual selection.
--
-- This function has “current” in its name because a function that returns the
-- last visual selection is also interesting.
--
--@treturn Region The current visual selection.
M.get_current_visual_selection = function()
	local cvim = require("coerce.vim")
	local region = require("coerce.region")

	local vmode = M.get_visual_mode()
	assert(vmode ~= nil, "Not in visual mode.")
	local rmode = nil
	if vmode == M.visual_mode.INLINE then
		rmode = region.modes.CHAR
	elseif vmode == M.visual_mode.LINE then
		rmode = region.modes.LINE
	elseif vmode == M.visual_mode.BLOCK then
		rmode = region.modes.BLOCK
	else
		assert(false, "Invalid visual mode: " .. vmode)
	end

	local s = cvim.fn.getpos("v")
	local e = cvim.fn.getpos(".")
	return region.region(rmode, s, e)
end

return M
