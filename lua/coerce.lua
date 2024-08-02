local M = {}

local case_m = require("coerce.case")
local coroutine_m = require("coerce.coroutine")
local selector_m = require("coerce.selector")
local transformer_m = require("coerce.transformer")
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
	{
		vim_mode = "n",
		keymap_prefix = "cr",
		selector = selector_m.select_current_word,
		transformer = function(selected_region, apply)
			return coroutine_m.fire_and_forget(
				transformer_m.transform_lsp_rename_with_local_failover,
				selected_region,
				apply
			)
		end,
	},
	{
		vim_mode = "n",
		keymap_prefix = "gcr",
		selector = selector_m.select_with_motion,
		transformer = transformer_m.transform_local,
	},
	{
		vim_mode = "v",
		keymap_prefix = "gcr",
		selector = selector_m.select_current_visual_selection,
		transformer = transformer_m.transform_local,
	},
}

---@class CoerceConfig
---@field keymap_registry KeymapRegistry?
---@field cases table
---@field modes table

M.default_config = {
	-- Avoid using the default registry here to avoid forcing clients to load Which Key.
	keymap_registry = nil,
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
	effective_config.keymap_registry = effective_config.keymap_registry or require("coerce.keymap").keymap_registry()

	coercer = conversion_m.Coercer(effective_config.keymap_registry, effective_config.notify)

	for _, mode in ipairs(effective_config.modes) do
		coercer:register_mode(mode)
	end

	for _, case in ipairs(effective_config.cases) do
		coercer:register_case(case)
	end
end

--- Tears down the plugin.
M.teardown = function()
	if coercer ~= nil then
		coercer:unregister_all()
		coercer = nil
	end
	effective_config = nil
end

return M
