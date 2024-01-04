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
--@tparam function user_operator_cb The operator callback.
--@tparam string mode The feedkeys() mode. Using “x” may be important to prevent laziness.
--@tparam string movement The movement to be used for the operator.
--@treturn nil
M.operator = function(user_operator_cb, mode, movement)
	movement = movement or ""
	M._operator_cb = user_operator_cb
	vim.o.operatorfunc = "v:lua.require'coerce.operator'._operator_cb"
	vim.api.nvim_feedkeys("g@" .. movement, mode or "m", false)
end

return M
