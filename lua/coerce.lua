local M = {}

M.default_config = {
	coerce_prefix = "cr",
}

--- Sets up the plugin.
--
--@tparam table|nil config
M.setup = function(config)
	config = vim.tbl_deep_extend("keep", config or {}, M.default_config)
	local conversion_m = require("coerce.conversion")
	local case_m = require("coerce.case")
	require("coerce.keymap").register({
		[config.coerce_prefix] = {
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
	})
end

return M
