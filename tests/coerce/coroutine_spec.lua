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

		it("works with an immediate callback-based function that returns multiple results", function()
			local f = function(cb, a, b)
				cb(a + b, a * b)
			end
			local f_co = cco.cb_to_co(f)
			local f_co_ret_sum, f_co_ret_mul = f_co(1, 2)
			assert.are.same(3, f_co_ret_sum)
			assert.are.same(2, f_co_ret_mul)
		end)

		it("converts a delayed callback-based function to a coroutine function", function()
			local f_cb = function() end
			-- f is a function that will “execute” the callback asynchronously through f_cb.
			local f = function(cb, a, b)
				f_cb = function()
					return cb(a + b)
				end
			end

			local f_co = coroutine.create(cco.cb_to_co(f))

			-- Resume the coroutine, which will call f and yield.
			coroutine.resume(f_co, 1, 2)

			-- Simulate the callback being called asynchronously.
			local f_co_ret = f_cb()

			assert.are.same(3, f_co_ret)
		end)

		it("works with a delayed callback-based function that returns multiple results", function()
			local f_cb = function() end
			-- f is a function that will “execute” the callback asynchronously through f_cb.
			local f = function(cb, a, b)
				f_cb = function()
					return cb(a + b, a * b)
				end
			end

			local f_co = coroutine.create(cco.cb_to_co(f))

			-- Resume the coroutine, which will call f and yield.
			coroutine.resume(f_co, 1, 2)

			-- Simulate the callback being called asynchronously.
			local f_co_ret_sum, f_co_ret_mul = f_cb()

			assert.are.same(3, f_co_ret_sum)
			assert.are.same(2, f_co_ret_mul)
		end)

		it("works with a delayed callback-based function that returns multiple results with nils", function()
			local f_cb = function() end
			-- f is a function that will “execute” the callback asynchronously through f_cb.
			local f = function(cb)
				f_cb = function()
					return cb("foo", nil, "bar", nil)
				end
			end

			local f_co = coroutine.create(cco.cb_to_co(f))

			-- Resume the coroutine, which will call f and yield.
			coroutine.resume(f_co)

			-- Simulate the callback being called asynchronously.
			local results = { f_cb() }

			assert.are.same({"foo", nil, "bar", nil}, results)
		end)

		it("rethrows errors after callback", function()
			local f_cb = function() end

			-- f is a function that will “execute” the callback asynchronously through f_cb.
			local f = function(cb)
				f_cb = function()
					return cb()
				end
			end

			local f_co = coroutine.create(function()
				cco.cb_to_co(f)()
				error("Catch me!")
			end)

			-- Resume the coroutine, which will call f and yield.
			coroutine.resume(f_co)

			-- Simulate the callback being called asynchronously.
			assert.has.errors(f_cb)
		end)
	end)
end)
