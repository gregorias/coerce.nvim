--- A module with text selectors.
--
-- A text selector is a function that returns a region of selected text.
--
-- @module coerce.selector
local M = {}

--- Selects the current word.
---
---@param cb function The callback to return the selected region to.
M.select_current_word = function(cb)
	local operator_m = require("coerce.operator")
	operator_m.operator_cb(function(mmode)
		local selected_region = operator_m.get_selected_region(mmode)
		cb(selected_region)
	end)
	vim.api.nvim_feedkeys("iw", "xn", false)
end

--- Selects with the user provided motion.
---
---@param cb function The callback to return the selected region to.
M.select_with_motion = function(cb)
	local operator_m = require("coerce.operator")
	-- The i-mode is important. We might be running within a feedkeys() call, so we need to insert
	-- the operator into the typeahead buffer immediately before the motion.
	-- The n-mode is also important. We don’t want user remaps of g@ to interfere with the operator.
	operator_m.operator_cb(function(mmode)
		local selected_region = operator_m.get_selected_region(mmode)
		cb(selected_region)
	end)
end

--- Selects the current visual selection.
--
-- This plugin is only meant to work with keywords, so this function fails if
-- the selected region is multiline.
--
-- @tparam function cb The callback to return the selected region to.
M.select_current_visual_selection = function(cb)
	local visual_m = require("coerce.visual")
	local selected_region = visual_m.get_current_visual_selection()
	local region = require("coerce.region")

	local selected_line_count = region.lines(selected_region)
	if selected_line_count > 1 then
		cb(selected_line_count .. " lines selected." .. " Coerce supports only single-line visual selections.")
	else
		cb(selected_region)
	end
end

return M
