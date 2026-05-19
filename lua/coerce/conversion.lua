---A module for enacting case conversions in Neovim.

--luacheck: max comment line length 200
local M = {}

--- Coerces selected text.
---
--- `select_text` uses a callback to support dot-repeat functionality. If `select_text` uses operators, then
--- the callback can be used as the repeatable action.
---
---@param select_text fun(cb: fun(region_or_error: coerce.Region | string)) The function that returns selected text (coerce.Region) or an error through a callback.
---@param transform_text fun(selected_region: coerce.Region, apply: fun(text: string): string) The function to use to transform selected text.
---@param case fun(text: string): string The function to use to coerce case.
---@param cb fun(error: string | nil) The function to receive a string error or nil.
---@return nil
M.coerce = function(select_text, transform_text, case, cb)
	select_text(function(selected_region)
		if type(selected_region) == "string" then
			cb(selected_region)
			return
		end
		transform_text(selected_region, case)
		cb(nil)
	end)
end

--- Converts the current word using the apply function.
---
--- This is a task function.
---
---@async
---@param transform_text fun(selected_region: coerce.Region, apply: fun(text: string): string) The function to transform the selected text.
---@param apply fun(text: string): string The case function to apply to the current word.
M.coerce_current_word = function(transform_text, apply)
	local selector = require("coerce.selector")
	M.coerce(selector.select_current_word, transform_text, apply, function() end)
end

---Coerces and runs post processing.
---
---@param mode coerce.Mode
---@param case coerce.CaseFunction
---@param notify function
---@return nil
M.coerce_and_post = function(mode, case, notify)
	M.coerce(mode.selector, mode.transformer, case, function(error)
		if type(error) == "string" then
			notify(error, "error", { title = "Coerce" })
		end
	end)
	if mode.post_processor then
		mode.post_processor()
	end
end

---Spawns a full coerce task with post processing.
---
---@param mode coerce.Mode
---@param case coerce.CaseFunction
---@param notify function
---@return nil
M.spawn_coerce = function(mode, case, notify)
	require("coop").spawn(function()
		M.coerce_and_post(mode, case, notify)
	end)
end

return M
