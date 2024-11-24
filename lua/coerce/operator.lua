--- Operator-related utilities.
--
-- Documentation on operators:
--
-- - https://neovim.io/doc/user/map.html#%3Amap-operator
-- - https://neovim.io/doc/user/options.html#'operatorfunc'
local M = {}

--- https://neovim.io/doc/user/map.html#g%40
---@alias motion_mode "line" | "char" | "block"

--- Possible motion modes used by operators.
M.motion_modes = {
	CHAR = "char",
	LINE = "line",
	BLOCK = "block",
}

-- A hidden variable to store the operator callback.
M._operator_cb = nil

--- Triggers an operator.
---
--- This function sets the operatorfunc option to the provided callback and immediately triggers the operator.
--- The operator will use the provided movement in the input buffer.
---
--- The provided callback can be used for dot-repeat.
---
---@param user_operator_cb fun(motion_mode) The operator callback.
M.operator_cb = function(user_operator_cb)
	M._operator_cb = user_operator_cb
	vim.o.operatorfunc = "v:lua.require'coerce.operator'._operator_cb"
	-- 'i' to insert. If we the user has typed "gUe" for uppercasing till end of the word and `gU` calls `operator_cb`,
	-- then `g@` needs to be inserted before the 'e'.
	-- 'n' to not remap. We want to trigger the operator.
	vim.api.nvim_feedkeys("g@", "in", false)
end

--- Triggers an operator.
--
-- This is a fire-and-forget coroutine function.
--
-- Unlike `operator_cb`, there is no useful callback remaining for the dot-repeat.
-- If you need dot-repeat, use operator_cb.
--
-- @tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
-- @tparam string movement The movement to be used for the operator.
-- @treturn coerce.region.Region The selected region.
M.operator = function(mode, movement)
	local mmode = require("coop.coroutine-utils").cb_to_co(function(cb)
		M.operator_cb(cb)
		vim.api.nvim_feedkeys(movement, mode, false)
	end)()
	local selected_region = M.get_selected_region(mmode)
	return selected_region
end

--- Gets the region selected by an operator motion.
---
---@param motion_mode motion_mode The motion mode.
---@return Region region The selected region.
M.get_selected_region = function(motion_mode)
	assert(motion_mode == M.motion_modes.CHAR, "Only supporting char motion for now.")
	local cvim = require("coerce.vim")

	local buffer = 0
	local sln = cvim.api.nvim_buf_get_mark(buffer, "[")
	local eln = cvim.api.nvim_buf_get_mark(buffer, "]")

	local region_m = require("coerce.region")
	return region_m.region(region_m.modes.CHAR, sln, eln)
end

return M
