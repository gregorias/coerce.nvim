---A module with final keymaps and their utilities.
local M = {}

---The main action function for coercing text. This is used by the keymaps.
---
---@param mode coerce.Mode
M.action = function(mode)
	local notify = require("coerce.vim.notify").notify
	local case_char = require("coerce.input").get_char()
	if case_char == nil then
		return
	end
	for _, case in ipairs(require("coerce.cases").cases) do
		if case_char == case.keymap then
			require("coerce.conversion").spawn_coerce(mode, case.case, notify)
			return
		end
	end
end

---Registers the plugin keymaps.
M.register_plug_keymaps = function()
	vim.keymap.set("n", "<Plug>(coerce-normal)", function()
		return M.action(require("coerce.mode").normal_mode)
	end, { desc = "Coerce word", silent = true })
	vim.keymap.set("n", "<Plug>(coerce-motion)", function()
		return M.action(require("coerce.mode").motion_mode)
	end, { desc = "Coerce motion", silent = true })
	vim.keymap.set("x", "<Plug>(coerce-visual)", function()
		return M.action(require("coerce.mode").visual_mode)
	end, { desc = "Coerce selection", silent = true })
end

---Creates Which Key expand function for case selection.
---
---@param mode coerce.Mode
---@return fun(): wk.Spec[]
local create_wk_expand = function(mode)
	return function()
		---@type wk.Spec[]
		local ret = {}
		for i, c in ipairs(require("coerce.cases").cases) do
			ret[i] = {
				[1] = c.keymap,
				[2] = function()
					local notify = require("coerce.vim.notify").notify
					return require("coerce.conversion").spawn_coerce(mode, c.case, notify)
				end,
				desc = c.description,
			}
		end
		return ret
	end
end

M.which_key_expand = {
	normal_mode = create_wk_expand(require("coerce.mode").normal_mode),
	motion_mode = create_wk_expand(require("coerce.mode").motion_mode),
	visual_mode = create_wk_expand(require("coerce.mode").visual_mode),
}

return M
