--- Test utilities.
local M = {}

--- Creates a buffer with the given content lines.
---
--- Also sets the buffer as the current buffer.
---
---@param content_lines table
---@return number buffer
M.create_buf = function(content_lines)
	local buf = vim.api.nvim_create_buf(--[[listed]] false, --[[scratch]] true)
	vim.api.nvim_buf_set_lines(
		--[[buffer]]
		buf,
		--[[start]]
		0,
		--[[end]]
		-1,
		--[[strict_indexing]]
		true,
		content_lines
	)
	vim.cmd("buffer " .. buf)
	return buf
end

--- Executes keys in the given mode.
---
--- This function also replaces termcodes like `<C-o>` into something that
--- feedkeys can understand.
---
---@param feedkeys string
---@param mode "n"|"v"|"i"|"x"
M.execute_keys = function(feedkeys, mode)
	local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
	vim.api.nvim_feedkeys(keys, mode, false)
end

return M
