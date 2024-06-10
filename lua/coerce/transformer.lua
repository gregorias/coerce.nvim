--- A module or transformers.
--
-- A transformers is a function that takes a selected region and a case, and
-- transforms the selected text using the case.
--
--@module coerce.transformer
local M = {}

--- Returns transformed selected text.
---
---@tparam Region selected_region The selected region to change.
---@tparam function apply The function to apply to the selected region.
---@treturn string
local apply_case_to_selected_region = function(selected_region, apply)
	local buffer = 0
	local region = require("coerce.region")
	assert(selected_region.mode == region.modes.CHAR)
	assert(region.lines(selected_region) <= 1)
	local va = require("coerce.vim.api")
	local selected_text_lines = va.nvim_buf_get_text(buffer, selected_region)
	return apply(selected_text_lines[1])
end

--- Changes the selected text with the apply function using local substitution.
---
---@tparam Region selected_region The selected region to change.
---@tparam function apply The function to apply to the selected region.
---@treturn boolean Whether the function has succeeded.
M.transform_local = function(selected_region, apply)
	local buffer = 0
	local region = require("coerce.region")
	assert(selected_region.mode == region.modes.CHAR)
	assert(region.lines(selected_region) <= 1)
	local transformed_text = apply_case_to_selected_region(selected_region, apply)
	vim.api.nvim_buf_set_text(
		buffer,
		selected_region.start_row,
		selected_region.start_col,
		selected_region.end_row - 1,
		selected_region.end_col,
		{ transformed_text }
	)
	return true
end

--- Changes the selected text with the apply function using LSP rename.
---
---@tparam Region selected_region The selected region to change.
---@tparam function apply The function to apply to the selected region.
---@treturn boolean Whether the function has succeeded.
M.transform_lsp_rename = function(selected_region, apply)
	if not require("coerce.vim.lsp").does_any_client_support_rename() then
		return false
	end
	local transformed_text = apply_case_to_selected_region(selected_region, apply)
	return vim.lsp.buf.rename(transformed_text)
end

--- Returns a transform functions that tries out all transforms until one works.
---
--- If any of the transforms is a coroutine function, the returned function will also be one.
---
---@treturn function
M.coalesce_transforms = function(transforms)
	local transform = function(...)
		for _, t in ipairs(transforms) do
			local success = t(...)
			if success then
				return true
			end
		end
		return false
	end
	return transform
end

--- Changes the selected text with the apply function using LSP rename.
--
-- The LSP rename only works on the symbol under the cursor, so it’s best not
-- to use this function for any other selection mode.
--
--@tparam Region selected_region The selected region to change.
--@tparam function apply The function to apply to the selected region.
--@treturn boolean Whether the function has succeeded.
M.transform_lsp_rename_with_local_failover = function(selected_region, apply)
	return M.coalesce_transforms({
		M.transform_lsp_rename,
		M.transform_local,
	})(selected_region, apply)
end

return M
