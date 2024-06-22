--- A module with text selectors.
--
-- A text selector is a function that returns a region of selected text.
--
-- @module coerce.selector
local M = {}

--- Selects the current word.
--
-- This is a fire-and-forget coroutine function.
--
-- @treturn Region The selected region.
M.select_current_word = function()
	local operator_m = require("coerce.operator")
	return operator_m.operator("xn", "iw")
end

--- Selects with the user provided motion.
--
-- This is a fire-and-forget coroutine function.
--
-- @treturn Region The selected region.
M.select_with_motion = function()
	local operator_m = require("coerce.operator")
	-- The i-mode is important. We might be running within a feedkeys() call, so we need to insert
	-- the operator into the typeahead buffer immediately before the motion.
	-- The n-mode is also important. We don’t want user remaps of g@ to interfere with the operator.
	return operator_m.operator("in", "")
end

--- Selects the current visual selection.
--
-- This plugin is only meant to work with keywords, so this function fails if
-- the selected region is multiline.
--
-- @treturn Region The selected region or an error.
M.select_current_visual_selection = function()
	local visual_m = require("coerce.visual")
	local selected_region = visual_m.get_current_visual_selection()
	local region = require("coerce.region")

	local selected_line_count = region.lines(selected_region)
	if selected_line_count > 1 then
		return (selected_line_count .. " lines selected." .. " Coerce supports only single-line visual selections.")
	end
	return selected_region
end

return M
