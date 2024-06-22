--- Operator-related utilities.
--
-- Documentation on operators:
--
-- - https://neovim.io/doc/user/map.html#%3Amap-operator
-- - https://neovim.io/doc/user/options.html#'operatorfunc'
local M = {}

--- Possible motion modes used by operators.
M.motion_modes = {
	CHAR = "char",
	LINE = "line",
	BLOCK = "block",
}

-- A hidden variable to store the operator callback.
M._operator_cb = nil

--- Triggers an operator.
--
-- This function sets the operatorfunc option to the provided callback and immediately triggers the operator.
--
-- This is a good way to work with operators, because these two actions are usually done together.
--
-- The provided callback will be used for dot-repeat.
--
-- @tparam function user_operator_cb The operator callback.
-- @tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
-- @tparam string movement The movement to be used for the operator.
-- @treturn nil
M.operator_cb = function(user_operator_cb, mode, movement)
	movement = movement or ""
	M._operator_cb = user_operator_cb
	vim.o.operatorfunc = "v:lua.require'coerce.operator'._operator_cb"
	vim.api.nvim_feedkeys("g@" .. movement, mode or "m", false)
end

--- Triggers an operator.
--
-- This is a fire-and-forget coroutine function.
--
-- Unlike `operator_cb`, there is no useful callback remaining for the dot-repeat. If you need dot-repeat, use
-- operator_cb.
--
-- @tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
-- @tparam string movement The movement to be used for the operator.
-- @treturn coerce.region.Region The selected region.
M.operator = function(mode, movement)
	local mmode = require("coerce.coroutine").cb_to_co(M.operator_cb)(mode, movement)
	local selected_region = M.get_selected_region(mmode)
	return selected_region
end

--- Gets the region selected by an operator motion.
--
-- @tparam string mode The motion mode.
-- @return coerce.region.Region The selected region.
M.get_selected_region = function(mode)
	assert(mode == M.motion_modes.CHAR, "Only supporting char motion for now.")
	local cvim = require("coerce.vim")

	local buffer = 0
	local sln = cvim.api.nvim_buf_get_mark(buffer, "[")
	local eln = cvim.api.nvim_buf_get_mark(buffer, "]")

	local region_m = require("coerce.region")
	return region_m.region(region_m.modes.CHAR, sln, eln)
end

return M
