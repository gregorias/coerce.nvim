local M = {}

local case_m = require("coerce.case")
local coroutine_m = require("coerce.coroutine")
local selector_m = require("coerce.selector")
local transformer_m = require("coerce.transformer")
local conversion_m = require("coerce.conversion")

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
}
---@class DefaultModeKeymapPrefixConfigOptional
---@field normal_mode? string
---@field motion_mode? string
---@field visual_mode? string

---@class DefaultModeKeymapPrefixConfig
---@field normal_mode string
---@field motion_mode string
---@field visual_mode string
M.default_mode_keymap_prefixes = {
	normal_mode = "cr",
	motion_mode = "gcr",
	visual_mode = "gcr",
}

---@param keymap_prefixes DefaultModeKeymapPrefixConfig
---@return any[]
M.get_default_modes = function(keymap_prefixes)
	return {
		{
			vim_mode = "n",
			keymap_prefix = keymap_prefixes.normal_mode,
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
			keymap_prefix = keymap_prefixes.motion_mode,
			selector = selector_m.select_with_motion,
			transformer = transformer_m.transform_local,
		},
		{
			vim_mode = "v",
			keymap_prefix = keymap_prefixes.visual_mode,
			selector = selector_m.select_current_visual_selection,
			transformer = transformer_m.transform_local,
		},
	}
end

---@class CoerceConfigUser
---@field keymap_registry? KeymapRegistry
---@field notify? function
---@field cases? table
---@field default_mode_keymap_prefixes? DefaultModeKeymapPrefixConfigOptional
---@field modes? table

---@class CoerceConfig
---@field keymap_registry KeymapRegistry
---@field notify function
---@field cases table
---@field modes table

---@param keymap_registry KeymapRegistry
---@param keymap_prefixes DefaultModeKeymapPrefixConfig
---@return CoerceConfig
M.get_default_config = function(keymap_registry, keymap_prefixes)
	return {
		-- Avoid using the default registry here to avoid forcing clients to load Which Key.
		keymap_registry = keymap_registry,
		notify = function(...)
			-- We call `vim.notify` lazily, so that we don’t bind vim.notify during the plugin’s setup.
			-- The user may modify `vim.notify` later.
			vim.notify(...)
		end,
		cases = M.default_cases,
		modes = M.get_default_modes(keymap_prefixes),
	}
end

---@param user_config CoerceConfigUser
---@return CoerceConfig
M.get_effective_config = function(user_config)
	local keymap_registry = user_config.keymap_registry or require("coerce.keymap").keymap_registry()
	local effective_keymap_prefixes =
		vim.tbl_deep_extend("force", M.default_mode_keymap_prefixes, user_config.default_mode_keymap_prefixes or {})
	local effective_config = M.get_default_config(keymap_registry, effective_keymap_prefixes)

	if user_config.notify then
		effective_config.notify = user_config.notify
	end
	if user_config.cases then
		effective_config.cases = user_config.cases
	end
	if user_config.modes then
		effective_config.modes = user_config.modes
	end
	return effective_config
end

local effective_config = nil

--- The singleton Coercer object.
--
-- It’s initialized with the config in `setup`.
local coercer = nil

--- Registers a new case.
---
---@param case table
M.register_case = function(case)
	assert(coercer ~= nil, "Coercer is not initialized.")
	coercer:register_case(case)
end

--- Registers a new mode.
---
---@param mode table
M.register_mode = function(mode)
	assert(coercer ~= nil, "Coercer is not initialized.")
	coercer:register_mode(mode)
end

--- Sets up the plugin.
---
---@param config? CoerceConfigUser
M.setup = function(config)
	effective_config = M.get_effective_config(config or {})

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
