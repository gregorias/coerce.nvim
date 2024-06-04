local cco = require("coerce.coroutine")

describe("coerce.coroutine", function()
	describe("cb_to_co", function()
		it("converts an immediate callback-based function to a coroutine function", function()
			local f = function(cb, a, b)
				cb(a + b)
			end
			local f_co = cco.cb_to_co(f)
			local f_co_ret = f_co(1, 2)
			assert.are.same(3, f_co_ret)
		end)

		it("converts a delayed callback-based function to a coroutine function", function()
			local f_cb = nil
			-- F is a function that will “execute” the callback asynchronously through f_cb.
			local f = function(cb, a, b)
				f_cb = function()
					return cb(a + b)
				end
			end

			local f_co = coroutine.create(cco.cb_to_co(f))

			-- Resume the coroutine, which will call f and block.
			coroutine.resume(f_co, 1, 2)

			-- Simulate the callback being called asynchronously.
			local f_co_ret = f_cb()

			assert.are.same(3, f_co_ret)
		end)
	end)
end)
