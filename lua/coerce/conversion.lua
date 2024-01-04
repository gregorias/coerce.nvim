--- A module for enacting case conversions in Neovim.
--
--@module coerce.conversion
local M = {}

--- Changes the the selected text using the apply function.
--
--@tparam Region selected_region The selected region to change.
--@tparam function apply The function to apply to the selected region.
--@treturn nil
M.substitute = function(selected_region, apply)
	local buffer = 0
	local region = require("coerce.region")
	assert(selected_region.mode == region.modes.CHAR_MODE)
	assert(region.lines(selected_region) <= 1)
	local vae = require("coerce.vim.api.extra")
	local selected_text_lines = vae.nvim_buf_get_text(buffer, selected_region)
	local transformed_text = apply(selected_text_lines[1])
	vim.api.nvim_buf_set_text(
		buffer,
		selected_region.start_row,
		selected_region.start_col,
		selected_region.end_row - 1,
		selected_region.end_col,
		{ transformed_text }
	)
end

return M
