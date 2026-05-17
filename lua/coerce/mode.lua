--luacheck: max line length 200
---A module for mode-related functionalities.
---
---A mode is a way of applying a case. It defines how a word is selected and transformed.
local M = {}

local selector_m = require("coerce.selector")

---@class coerce.Mode
---@field selector fun(cb: fun(region_or_error: coerce.Region | string)): nil @A function that selects a region of text. It takes a callback that receives either a region or an error message.
---@field transformer fun(selected_region: coerce.Region, apply: coerce.CaseFunction)
---@field post_processor? fun(): nil @A function that is called after the coercion is done.

---@type coerce.Mode
M.normal_mode = {
	selector = selector_m.select_current_word,
	transformer = function(selected_region, apply)
		local transformer_m = require("coerce.transformer")
		return require("coop").spawn(
			transformer_m.transform_lsp_rename_with_local_failover,
			selected_region,
			apply
		)
	end,
}

---@type coerce.Mode
M.motion_mode = {
	selector = selector_m.select_with_motion,
	transformer = function(...)
		local transformer_m = require("coerce.transformer")
		return transformer_m.transform_local(...)
	end,
}

---@type coerce.Mode
M.visual_mode = {
	selector = selector_m.select_current_visual_selection,
	transformer = function(...)
		local transformer_m = require("coerce.transformer")
		return transformer_m.transform_local(...)
	end,
	post_processor = function()
		-- Exit visual mode after the coercion is done.
		-- That’s how built-in commands work, e.g., `d`elete.
		-- Requested in #11.
		local esc = vim.keycode("<esc>")
		vim.api.nvim_feedkeys(esc, "nx", false)
	end,
}

return M
