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
-- This function sets the operatorfunc option to a function and immediately triggers the operator.
--
-- This is a good way to work with operators, because these two actions are usually done together.
--
-- Prefer using operator() instead of this function. Callback-hell is less readable.
--
--@tparam function user_operator_cb The operator callback.
--@tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
--@tparam string movement The movement to be used for the operator.
--@treturn nil
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
--@tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
--@tparam string movement The movement to be used for the operator.
--@treturn coerce.region.Region The selected region.
M.operator = function(mode, movement)
	local mmode = require("coerce.coroutine").cb_to_co(M.operator_cb)(mode, movement)
	local selected_region = M.get_selected_region(mmode)
	return selected_region
end

--- Gets the region selected by an operator motion.
--
--@tparam string mode The motion mode.
--@return coerce.region.Region The selected region.
M.get_selected_region = function(mode)
	assert(mode == M.motion_modes.CHAR, "Only supporting char motion for now.")
	local cvim = require("coerce.vim")

	local buffer = 0
	local sln = cvim.api.nvim_buf_get_mark(buffer, "[")
	local eln = cvim.api.nvim_buf_get_mark(buffer, "]")

	-- if mode == M.motion_modes.LINE then
	--   sln = { sln[1], 0 }
	--   eln = { eln[1], vim.fn.getline(eln[1]):len() - 1 }
	-- end

	-- Make sure we we change start and end if end is higher than start.
	-- This happens when we select from bottom to top or from right to left.
	local start_row = math.min(sln[1], eln[1])
	local start_col = math.min(sln[2], eln[2])
	local end_row = math.max(sln[1], eln[1]) + 1
	local end_col_1 = math.min(sln[2], vim.fn.getline(sln[1] + 1):len()) + 1
	local end_col_2 = math.min(eln[2], vim.fn.getline(eln[1] + 1):len()) + 1
	local end_col = math.max(end_col_1, end_col_2)

	local region = require("coerce.region")
	return {
		mode = region.modes.CHAR,
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

return M
