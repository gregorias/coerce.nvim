--- A module with utilities for manipulating keymaps.
--
-- @module coerce.keymap
local M = {}

---@class KeymapRegistry
---@field register_keymap_group fun(mode: string, keymap: string, description: string): nil
---@field unregister_keymap_group fun(mode: string, keymap: string): nil
---@field register_keymap fun(mode: string, keymap: string, action: string, description: string): nil
---@field unregister_keymap fun(mode: string, keymap: string): nil

---@type KeymapRegistry
M.plain_keymap_registry = {
	register_keymap_group = function()
		return nil
	end,
	unregister_keymap_group = function()
		return nil
	end,
	register_keymap = function(mode, keymap, action, description)
		vim.keymap.set(mode, keymap, action, { desc = description })
	end,
	unregister_keymap = function(mode, keymap)
		vim.keymap.del(mode, keymap)
	end,
}

---@type KeymapRegistry
M.which_key_keymap_registry = {
	register_keymap_group = function(mode, keymap, description)
		require("which-key").add({ { [1] = keymap, group = description, mode = mode } })
	end,
	unregister_keymap_group = function(mode, keymap)
		require("which-key").add({ { [1] = keymap, group = "which_key_ignore", mode = mode } })
		vim.keymap.del(mode, keymap)
	end,
	register_keymap = function(mode, keymap, action, description)
		require("which-key").add({ { [1] = keymap, [2] = action, desc = description, mode = mode } })
	end,
	unregister_keymap = function(mode, keymap)
		local wk = require("which-key")
		wk.add({
			{
				[1] = keymap,
				[2] = "which_key_ignore",
				desc = "which_key_ignore",
				mode = mode,
			},
		})
		vim.keymap.del(mode, keymap)
	end,
}

--- Returns a keymap registry.
--
---@return KeymapRegistry
M.keymap_registry = function()
	local which_key_status, _ = pcall(require, "which-key")
	if which_key_status then
		return M.which_key_keymap_registry
	else
		return M.plain_keymap_registry
	end
end

return M
