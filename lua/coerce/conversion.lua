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
--@tparam string coerce_prefix
M.Coercer = function(keymap_registry)
	return {
		keymap_registry = keymap_registry,
		registered_cases = {},
		registered_modes = {},

		_register_mode_case = function(self, mode, case)
			self.keymap_registry.register_keymap(mode.vim_mode, mode.keymap_prefix .. case.keymap, function()
				local coroutine_m = require("coerce.coroutine")
				coroutine_m.fire_and_forget(function()
					M.coerce(mode.selector, case.case)
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

--- Changes the the selected text using the apply function.
--
--@tparam Region selected_region The selected region to change.
--@tparam function apply The function to apply to the selected region.
--@treturn nil
M.substitute = function(selected_region, apply)
	local buffer = 0
	local region = require("coerce.region")
	assert(selected_region.mode == region.modes.CHAR)
	assert(region.lines(selected_region) <= 1)
	local va = require("coerce.vim.api")
	local selected_text_lines = va.nvim_buf_get_text(buffer, selected_region)
	local transformed_text = apply(selected_text_lines[1])
	vim.api.nvim_buf_set_text(
		buffer,
		selected_region.start_row,
		selected_region.start_col,
		selected_region.end_row - 1,
		selected_region.end_col,
		{ transformed_text }
	)
end

--- Selects the current word.
--
-- This is a fire-and-forget coroutine function.
--
--@treturn Region The selected region.
M.select_current_word = function()
	local operator_m = require("coerce.operator")
	return operator_m.operator("x", "iw")
end

--- Coerces selected text.
--
--@tparam function select_text The function that returns selected text.
--@tparam function transform_text The function to use to transform selected text.
M.coerce = function(select_text, transform_text)
	local selected_region = select_text()
	M.substitute(selected_region, transform_text)
end

--- Converts the current word using the apply function.
--
-- This is a fire-and-forget coroutine function.
--
--@tparam function apply The function to apply to the current word.
--@treturn nil
M.coerce_current_word = function(apply)
	M.coerce(M.select_current_word, apply)
end

return M
