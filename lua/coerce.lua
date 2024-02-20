local M = {}

local case_m = require("coerce.case")
local selector_m = require("coerce.selector")
local conversion_m = require("coerce.conversion")

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

M.default_modes = {
	{ vim_mode = "n", keymap_prefix = "cr", selector = selector_m.select_current_word },
	{ vim_mode = "n", keymap_prefix = "gcr", selector = selector_m.select_with_motion },
	{ vim_mode = "v", keymap_prefix = "cr", selector = selector_m.select_current_visual_selection },
}

M.default_config = {
	keymap_registry = require("coerce.keymap").keymap_registry(),
	notify = function(...)
		-- We call `vim.notify` lazily, so that we don’t bind vim.notify during the plugin’s setup.
		-- The user may modify `vim.notify` later.
		vim.notify(...)
	end,
	cases = M.default_cases,
	modes = M.default_modes,
}

--- The singleton Coercer object.
--
-- It’s initialized with the config in `setup`.
local coercer = nil
local effective_config = nil

--- Registers a new case.
--
--@tparam table case
M.register_case = function(case)
	assert(coercer ~= nil, "Coercer is not initialized.")
	coercer:register_case(case)
end

--- Registers a new mode.
--
--@tparam table mode
M.register_mode = function(mode)
	assert(coercer ~= nil, "Coercer is not initialized.")
	coercer:register_mode(mode)
end

--- Sets up the plugin.
--
--@tparam table|nil config
M.setup = function(config)
	effective_config = vim.tbl_deep_extend("keep", config or {}, M.default_config)

	coercer = conversion_m.Coercer(effective_config.keymap_registry, effective_config.notify)

	for _, mode in ipairs(effective_config.modes) do
		coercer:register_mode(mode)
	end

	for _, case in ipairs(effective_config.cases) do
		coercer:register_case(case)
	end
end

return M
