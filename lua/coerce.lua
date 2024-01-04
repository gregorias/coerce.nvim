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
			c = {
				function()
					conversion_m.convert_current_word(case_m.to_camel_case)
				end,
				"camelCase",
			},
			d = {
				function()
					conversion_m.convert_current_word(case_m.to_dot_case)
				end,
				"dot.case",
			},
			k = {
				function()
					conversion_m.convert_current_word(case_m.to_kebab_case)
				end,
				"kebab-case",
			},
			n = {
				function()
					conversion_m.convert_current_word(case_m.to_numerical_contraction)
				end,
				"numerical contraction (n18n)",
			},
			p = {
				function()
					conversion_m.convert_current_word(case_m.to_pascal_case)
				end,
				"PascalCase",
			},
			s = {
				function()
					conversion_m.convert_current_word(case_m.to_snake_case)
				end,
				"snake_case",
			},
			u = {
				function()
					conversion_m.convert_current_word(case_m.to_upper_case)
				end,
				"UPPER_CASE",
			},
		},
		[CHANGE_CASE_PREFIX] = {
			name = "+Change Case",
		},
	})
end

return M
