--- A module for enacting case conversions in Neovim.
--
--@module coerce.conversion
local M = {}

M.registered_cases = {}
M.registered_modes = {}

--- Constructs a Coercer object.
--
-- Coercer is meant to be a singleton object that handles registering new
-- cases and modes, and actuating them.
--
--@tparam table keymap_registry
--@tparam function notify The notification function to use.
--@tparam string coerce_prefix
M.Coercer = function(keymap_registry, notify)
	return {
		keymap_registry = keymap_registry,
		notify = notify,
		registered_cases = {},
		registered_modes = {},

		_register_mode_case = function(self, mode, case)
			self.keymap_registry.register_keymap(mode.vim_mode, mode.keymap_prefix .. case.keymap, function()
				local coroutine_m = require("coerce.coroutine")
				coroutine_m.fire_and_forget(function()
					local error = M.coerce(mode.selector, mode.transformer, case.case)
					if type(error) == "string" then
						self.notify(error, "error", { title = "Coerce" })
					end
				end)
			end, case.description)
		end,

		--- Registers a new case.
		--
		--@tparam {keymap=string, description=string, case=function}
		--@treturn nil
		register_case = function(self, case)
			table.insert(self.registered_cases, case)

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

			for _, case in ipairs(self.registered_cases) do
				self:_register_mode_case(mode, case)
			end
		end,
	}
end

--- Coerces selected text.
--
--@tparam function select_text The function that returns selected text (Region) or an error.
--@tparam function transform_text The function to use to transform selected text.
--@tparam function case The function to use to coerce case.
M.coerce = function(select_text, transform_text, case)
	local selected_region = select_text()
	if type(selected_region) == "string" then
		return selected_region
	end
	transform_text(selected_region, case)
end

--- Converts the current word using the apply function.
--
-- This is a fire-and-forget coroutine function.
--
--@tparam function apply The function to transform the selected text.
--@tparam function apply The case function to apply to the current word.
--@treturn nil
M.coerce_current_word = function(transform_text, apply)
	local selector = require("coerce.selector")
	M.coerce(selector.select_current_word, transform_text, apply)
end

return M
