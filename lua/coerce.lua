local M = {}

local case_m = require("coerce.case")
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
	{ keymap = " ", case = case_m.to_space_case, description = "space case" },
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

---@class DefaultModeMask
---@field normal_mode? boolean
---@field motion_mode? boolean
---@field visual_mode? boolean
M.default_mode_mask = {
	normal_mode = true,
	motion_mode = true,
	visual_mode = true,
}

---@class Mode
---@field vim_mode string
---@field keymap_prefix string
---@field selector function
---@field transformer function
---@field post_processor? function The function to run after the coercion.

--- Gets the default modes
---
---@param mode_mask DefaultModeMask
---@param keymap_prefixes DefaultModeKeymapPrefixConfig
---@return Mode[]
M.get_default_modes = function(mode_mask, keymap_prefixes)
	---@type Mode[]
	local modes = {}
	if mode_mask.normal_mode ~= false then
		table.insert(modes, {
			vim_mode = "n",
			keymap_prefix = keymap_prefixes.normal_mode,
			selector = selector_m.select_current_word,
			transformer = function(selected_region, apply)
				return require("coop.coroutine-utils").fire_and_forget(
					transformer_m.transform_lsp_rename_with_local_failover,
					selected_region,
					apply
				)
			end,
		})
	end

	if mode_mask.motion_mode ~= false then
		table.insert(modes, {
			vim_mode = "n",
			keymap_prefix = keymap_prefixes.motion_mode,
			selector = selector_m.select_with_motion,
			transformer = transformer_m.transform_local,
		})
	end

	if mode_mask.visual_mode ~= false then
		table.insert(modes, {
			vim_mode = "v",
			keymap_prefix = keymap_prefixes.visual_mode,
			selector = selector_m.select_current_visual_selection,
			transformer = transformer_m.transform_local,
			post_processor = function()
				local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
				vim.api.nvim_feedkeys(esc, "nx", false)
			end,
		})
	end

	return modes
end

---@class CoerceConfigUser
---@field keymap_registry? KeymapRegistry
---@field notify? function
---@field cases? table
---@field default_mode_keymap_prefixes? DefaultModeKeymapPrefixConfigOptional
---@field default_mode_mask? DefaultModeMask
---@field modes? Mode[]

---@class CoerceConfig
---@field keymap_registry KeymapRegistry
---@field notify function
---@field cases table
---@field modes Mode[]

---@param keymap_registry KeymapRegistry
---@param default_mode_mask DefaultModeMask
---@param keymap_prefixes DefaultModeKeymapPrefixConfig
---@return CoerceConfig
M.get_default_config = function(keymap_registry, default_mode_mask, keymap_prefixes)
	return {
		-- Avoid using the default registry here to avoid forcing clients to load Which Key.
		keymap_registry = keymap_registry,
		notify = function(...)
			-- We call `vim.notify` lazily, so that we don’t bind vim.notify during the plugin’s setup.
			-- The user may modify `vim.notify` later.
			vim.notify(...)
		end,
		cases = M.default_cases,
		modes = M.get_default_modes(default_mode_mask, keymap_prefixes),
	}
end

---@param user_config CoerceConfigUser
---@return CoerceConfig
M.get_effective_config = function(user_config)
	local keymap_registry = user_config.keymap_registry or require("coerce.keymap").keymap_registry()
	local effective_keymap_prefixes =
		vim.tbl_deep_extend("force", M.default_mode_keymap_prefixes, user_config.default_mode_keymap_prefixes or {})

	local default_mode_mask = vim.tbl_deep_extend("force", M.default_mode_mask, user_config.default_mode_mask or {})

	local effective_config = M.get_default_config(keymap_registry, default_mode_mask, effective_keymap_prefixes)

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
---@param mode Mode
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
