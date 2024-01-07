local M = {}

M.default_config = {
	coerce_prefix = "cr",
	keymap_registry = require("coerce.keymap").keymap_registry(),
}

local case_m = require("coerce.case")

--- The default cases to use.
M.default_cases = {
	{ keymap = "c", case = case_m.to_camel_case, description = "camelCase" },
	{ keymap = "d", case = case_m.to_dot_case, description = "dot.case" },
	{ keymap = "k", case = case_m.to_kebab_case, description = "kebab-case" },
	{ keymap = "n", case = case_m.to_numerical_contraction, description = "numerical contraction (n18n)" },
	{ keymap = "p", case = case_m.to_pascal_case, description = "PascalCase" },
	{ keymap = "s", case = case_m.to_snake_case, description = "snake_case" },
	{ keymap = "u", case = case_m.to_upper_case, description = "UPPER_CASE" },
	{ keymap = "/", case = case_m.to_path_case, description = "path/case" },
}

local effective_config = nil

--- Registers a new case.
--
--tparam table args
M.register = function(case)
	case.coerce_prefix = effective_config.coerce_prefix
	case.keymap_registry = effective_config.keymap_registry
	require("coerce.conversion").register(case)
end

--- Sets up the plugin.
--
--@tparam table|nil config
M.setup = function(config)
	effective_config = vim.tbl_deep_extend("keep", config or {}, M.default_config)
	for _, case in ipairs(M.default_cases) do
		M.register(case)
	end
end

return M
