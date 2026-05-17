---The registry of all cases.
local M = {}

---The case function with metadata.
---
---@class coerce.Case
---@field case fun(str: string): string @The function to convert a string into this case.
---@field keymap string @The keymap to trigger this case.
---@field description string @The description of this case, to be shown in Which Key.

---The registry of all cases.
---
---@type table<integer, coerce.Case>
M.cases = {}

---Registers a new case.
---
---@param case coerce.Case
---@return nil
M.register_case = function(case)
	table.insert(M.cases, case)
end

---Unregisters all cases.
---
---@return nil
M.unregister_all_cases = function()
	M.cases = {}
end

return M
