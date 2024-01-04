local M = {}

local COERCE_PREFIX = "cr"
local CHANGE_CASE_PREFIX = "gc"

--- Sets up the plugin.
M.setup = function()
	local conversion_m = require("coerce.conversion")
	local case_m = require("coerce.case")
	require("coerce.keymap").register({
		[COERCE_PREFIX] = {
			name = "+Coerce to...",
			n = {
				function()
					conversion_m.convert_current_word(case_m.to_numerical_contraction)
				end,
				"numerical contraction",
			},
		},
		[CHANGE_CASE_PREFIX] = {
			name = "+Change Case",
		},
	})
end

return M
