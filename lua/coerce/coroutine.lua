--- A module with utilities for coroutines.
local M = {}

local pack = function(...)
	-- selene: allow(mixed_table)
	return { n = select("#", ...), ... }
end

--- Converts a callback-based function to a coroutine function.
---
--- A coroutine function is a function (not a coroutine/thread) that must be run
--- within a coroutine as it may use coroutine facilities such as yielding.
---
--- The point of this conversion is to allow the programmer to write code that
--- looks synchronous. That is only possible when the programmer works within a
--- coroutine that can be transparently paused.
---
---@tparam function f The function to convert. The callback needs to be its
---                   first argument.
---@treturn function A coroutine function. Accepts the same arguments as f
---                  without the callback. Returns what f has passed to the
---                  callback.
M.cb_to_co = function(f)
	local f_co = function(...)
		local this = coroutine.running()
		assert(this ~= nil, "The result of cb_to_co must be called within a coroutine.")

		local f_status = "running"
		local f_ret = pack()
		-- f needs to have the callback as its first argument, because varargs
		-- passing doesn’t work otherwise.
		f(function(...)
			f_status = "done"
			f_ret = pack(...)
			if coroutine.status(this) == "suspended" then
				-- If we are suspended, then we f_co has yielded control after calling f.
				-- Use the caller of this callback to resume computation until the next yield.
				local cb_ret = pack(coroutine.resume(this))
				if not cb_ret[1] then
					error(cb_ret[2])
				end
				return unpack(cb_ret, 2, cb_ret.n)
			end
		end, ...)
		if f_status == "running" then
			-- If we are here, then `f` must not have called the callback yet, so it
			-- will do so asynchronously.
			-- Yield control and wait for the callback to resume it.
			coroutine.yield()
		end
		return unpack(f_ret, 1, f_ret.n)
	end

	return f_co
end

--- Fires and forgets a coroutine function.
---
---@tparam function f_co The coroutine function to fire and forget.
---@treturn nil
M.fire_and_forget = function(f_co, ...)
	coroutine.resume(coroutine.create(f_co), ...)
end

return M
