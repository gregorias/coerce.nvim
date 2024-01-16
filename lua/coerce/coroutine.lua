--- A module with utilities for coroutines.
local M = {}

--- Converts a callback-based function to a coroutine function.
--
-- A coroutine function is a function (not a coroutine/thread) that must be run
-- within a coroutine as it may use coroutine facilities such as yielding.
--
-- The point of this conversion is to allow the programmer to write code that
-- looks synchronous. That is only possible the programmer works within a
-- coroutine that can be transparently paused.
--
-- Example use:
--
-- ```
-- -- read_file : function(cb, path) -> string
-- -- delete_file : function(cb, path) -> nil
--
-- print_and_delete = function(path)
--   contents = cb_to_co(read_file)(path)
--   print(contents)
--   cb_to_co(delete_file)(path)
-- end
--
-- main = function()
--   -- Fire and forget. This may yield back to main before truly finishing.
--   -- The callbacks will resume it.
--   coroutine.resume(coroutine.create(print_and_delete))
-- end
-- ```
--
--@tparam function f The function to convert. The callback needs to be its
--                   first argument.
--@treturn function A coroutine function. Accepts the same arguments as f
--                  without the callback.
M.cb_to_co = function(f)
	local f_co = function(...)
		local this = coroutine.running()
		assert(this ~= nil, "The result of cb_to_co must be called within a coroutine.")

		local f_status = "running"
		local f_ret = nil
		-- f needs to have the callback as its first argument, because varargs
		-- passing doesn’t work otherwise.
		f(function(ret)
			f_status = "done"
			f_ret = ret
			if coroutine.status(this) == "suspended" then
				local _, cb_ret = coroutine.resume(this)
				return cb_ret
			end
		end, ...)
		if f_status == "running" then
			-- Yield control and wait for the callback to resume it.
			coroutine.yield()
		end
		return f_ret
	end

	return f_co
end

return M
