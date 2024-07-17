--- A module with utilities for manipulating keymaps.
--
-- @module coerce.keymap
local M = {}

---@class KeymapRegistry
---@field register_keymap_group fun(mode: string, keymap: string, description: string): nil
---@field register_keymap fun(mode: string, keymap: string, action: string, description: string): nil

---@type KeymapRegistry
M.plain_keymap_registry = {
	register_keymap_group = function()
		return nil
	end,
	register_keymap = function(mode, keymap, action, description)
		vim.keymap.set(mode, keymap, action, { desc = description })
	end,
}

---@type KeymapRegistry
M.which_key_keymap_registry = {
	register_keymap_group = function(mode, keymap, description)
		require("which-key").add({ { [1] = keymap, group = description, mode = mode } })
		-- Fixes a bug, where the WhichKey window doesn’t show up in when there’s a conflicting prefix, e.g., `gcr` is used
		-- for Coerce, but `gc` is used for commenting.
		vim.keymap.set(mode, keymap, function()
			local wk_mode = mode
			if mode == "v" then
				wk_mode = "x"
			end
			require("which-key").show({ keys = keymap, mode = wk_mode })
		end)
	end,
	register_keymap = function(mode, keymap, action, description)
		require("which-key").add({ { [1] = keymap, [2] = action, desc = description, mode = mode } })
	end,
}

---@return KeymapRegistry
M.keymaster_keymap_registry = function(keymaster)
	return {
		register_keymap_group = function(mode, keymap, description)
			keymaster.set({
				[keymap] = { name = description },
			}, { mode = mode })
		end,
		register_keymap = function(mode, keymap, action, description)
			keymaster.set({
				[keymap] = {
					action,
					description,
				},
			}, { mode = mode })
		end,
	}
end

--- Returns a keymap registry.
--
---@return KeymapRegistry
M.keymap_registry = function()
	local keymaster_status, keymaster = pcall(require, "keymaster")
	if keymaster_status then
		return M.keymaster_keymap_registry(keymaster)
	end

	local which_key_status, _ = pcall(require, "which-key")
	if which_key_status then
		return M.which_key_keymap_registry
	else
		return M.plain_keymap_registry
	end
end

return M
