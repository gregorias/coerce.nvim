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
		require("which-key").register({
			[keymap] = { name = description },
		}, { mode = mode })
		-- Fixes a bug, where the WhichKey window doesn’t show up in the visual mode.
		-- The open bug in question: https://github.com/folke/which-key.nvim/issues/458.
		if mode == "v" or mode == "x" then
			vim.keymap.set(mode, keymap, "<cmd>WhichKey " .. keymap .. " " .. mode .. "<cr>")
		end
	end,
	register_keymap = function(mode, keymap, action, description)
		require("which-key").register({
			[keymap] = {
				action,
				description,
			},
		}, { mode = mode })
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
