local M = {}

local case_m = require("coerce.case")

--------------------------------------------------------------------------------
--- Configuration
--------------------------------------------------------------------------------

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
	{ keymap = " ", case = case_m.to_space_case, description = "space case" },
}

---@class CoerceConfigUser
---@field cases? table

---@class CoerceConfig
---@field cases table

---@return CoerceConfig
M.get_default_config = function()
	return {
		cases = M.default_cases,
	}
end

---@param user_config CoerceConfigUser
---@return CoerceConfig
M.get_effective_config = function(user_config)
	local effective_config = M.get_default_config()

	if user_config.cases then
		effective_config.cases = user_config.cases
	end
	return effective_config
end

local effective_config = nil

---Registers a new case.
---
---@param case coerce.Case
M.register_case = function(case)
	require("coerce.cases").register_case(case)
end

--- Sets up the plugin.
---
---@param config? CoerceConfigUser
M.setup = function(config)
	effective_config = M.get_effective_config(config or {})
	for _, case in ipairs(effective_config.cases) do
		M.register_case(case)
	end
	require("coerce.keymaps").register_plug_keymaps()
end

---Tears down the plugin.
M.teardown = function()
	require("coerce.cases").unregister_all_cases()
	effective_config = nil
end

return M
