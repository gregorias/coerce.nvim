--- A module for enacting case conversions in Neovim.
--
--@module coerce.conversion
local M = {}

M.registered_cases = {}
M.registered_modes = {}

--- Registers a new case.
M.register = function(args)
	args.keymap_registry.register_keymap(args.coerce_prefix .. args.keymap, function()
		local coroutine_m = require("coerce.coroutine")
		coroutine_m.fire_and_forget(M.coerce_current_word, args.case)
	end, args.description)
end

--- Constructs a Coercer object.
--
-- Coercer is meant to be a singleton object that handles registering new
-- cases and modes, and actuating them.
--
--@tparam table keymap_registry
--@tparam string coerce_prefix
M.Coercer = function(keymap_registry, coerce_prefix)
	return {
		keymap_registry = keymap_registry,
		coerce_prefix = coerce_prefix,
		registered_cases = {},

		--- Registers a new case.
		--
		--@tparam {keymap=string, description=string, case=function}
		--@treturn nil
		register_case = function(self, case)
			table.insert(self.registered_cases, case)

			self.keymap_registry.register_keymap(self.coerce_prefix .. case.keymap, function()
				local coroutine_m = require("coerce.coroutine")
				coroutine_m.fire_and_forget(M.coerce_current_word, case.case)
			end, case.description)
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
local select_current_word = function()
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
	M.coerce(select_current_word, apply)
end

return M
