--- A module with utilities for manipulating keymaps.
--
-- @module coerce.keymap
local M = {}

--- Registers a new keymap.
--
--@tparam table spec A WhichKey spec.
--@treturn nil
M.register = function(spec)
	require("which-key").register(spec)
end

return M
