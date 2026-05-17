--- A module for enacting case conversions in Neovim.

--luacheck: max comment line length 200
local M = {}

M.registered_modes = {}

--- Constructs a Coercer object.
---
--- Coercer is meant to be a singleton object that handles registering new
--- cases and modes, and actuating them.
---
---@param keymap_registry table
---@param notify function The notification function to use.
M.Coercer = function(keymap_registry, notify)
	return {
		keymap_registry = keymap_registry,
		notify = notify,
		registered_modes = {},

		---@param mode CoerceMode
		---@param case any
		_register_mode_case = function(self, mode, case)
			self.keymap_registry.register_keymap(
				mode.vim_mode,
				mode.keymap_prefix .. case.keymap,
				function()
					require("coop").spawn(function()
						M.coerce(mode.selector, mode.transformer, case.case, function(error)
							if type(error) == "string" then
								self.notify(error, "error", { title = "Coerce" })
							end
						end)
						if mode.post_processor then
							mode.post_processor()
						end
					end)
				end,
				case.description
			)
		end,

		_unregister_mode_case = function(self, mode, case)
			self.keymap_registry.unregister_keymap(mode.vim_mode, mode.keymap_prefix .. case.keymap)
		end,

		--- Registers a new case.
		--
		--@tparam {keymap=string, description=string, case=function}
		--@treturn nil
		register_case = function(self, case)
			require("coerce.cases").register_case(case)

			for _, mode in ipairs(self.registered_modes) do
				self:_register_mode_case(mode, case)
			end
		end,

		--- Registers a new mode.
		--
		--@tparam { keymap_prefix=string, selector=function }
		register_mode = function(self, mode)
			table.insert(self.registered_modes, mode)
			self.keymap_registry.register_keymap_group(mode.vim_mode, mode.keymap_prefix, "+Coerce")

			for _, case in ipairs(require("coerce.cases").cases) do
				self:_register_mode_case(mode, case)
			end
		end,

		--- Unregisters all cases and modes.
		unregister_all = function(self)
			for _, mode in ipairs(self.registered_modes) do
				for _, case in ipairs(require("coerce.cases").cases) do
					self:_unregister_mode_case(mode, case)
				end
				self.keymap_registry.unregister_keymap_group(mode.vim_mode, mode.keymap_prefix)
			end
			require("coerce.cases").unregister_all_cases()
			self.registered_modes = {}
		end,
	}
end

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

return M
