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
	{ keymap = "n", case = case_m.to_numerical_contraction, description = "numeronym (n7m)" },
	{ keymap = "p", case = case_m.to_pascal_case, description = "PascalCase" },
	{ keymap = "s", case = case_m.to_snake_case, description = "snake_case" },
	{ keymap = "u", case = case_m.to_upper_case, description = "UPPER_CASE" },
	{ keymap = "/", case = case_m.to_path_case, description = "path/case" },
}

--- The singleton Coercer object.
--
-- It’s initialized with the config in `setup`.
local coercer = nil
local effective_config = nil

--- Registers a new case.
--
--@tparam table args
M.register_case = function(case)
	assert(coercer ~= nil, "Coercer is not initialized.")
	coercer:register_case(case)
end

--- Sets up the plugin.
--
--@tparam table|nil config
M.setup = function(config)
	effective_config = vim.tbl_deep_extend("keep", config or {}, M.default_config)
	effective_config.keymap_registry.register_keymap_group(effective_config.coerce_prefix, "+Coerce")

	local conversion_m = require("coerce.conversion")

	coercer = conversion_m.Coercer(effective_config.keymap_registry, effective_config.coerce_prefix)
	for _, case in ipairs(M.default_cases) do
		coercer:register_case(case)
	end
end

return M
