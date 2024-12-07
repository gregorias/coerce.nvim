--- Extra vim.api utilities.
--
--@module coerce.vim.api
local M = {}

--- An alternative to nvim_buf_get_text that is zero-indexed.
---
---@param buffer number The buffer to get the text from.
---@param mark string The mark to get.
---@return table t A 2-tuple of the mark.
M.nvim_buf_get_mark = function(buffer, mark)
	local pos = vim.api.nvim_buf_get_mark(buffer, mark)
	return { pos[1] - 1, pos[2] }
end

--- Gets the text of a region of a buffer.
--
--@tparam number buffer The buffer to get the text from.
--@tparam coerce.region.Region region The region to get the text from.
--@treturn table The text lines of the region.
M.nvim_buf_get_text = function(buffer, region)
	local region_m = require("coerce.region")
	assert(
		region.mode == region_m.modes.CHAR,
		"Only char regions are supported, but got: " .. vim.inspect(region)
	)
	local lines = vim.api.nvim_buf_get_lines(
		buffer,
		region.start_row,
		region.end_row,
		--[[strict_indexing]]
		false
	)
	lines[vim.tbl_count(lines)] = string.sub(lines[vim.tbl_count(lines)], 0, region.end_col)
	lines[1] = string.sub(lines[1], region.start_col + 1)
	return lines
end

return M
