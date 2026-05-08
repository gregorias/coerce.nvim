local cc = require("coerce.conversion")
local transformer = require("coerce.transformer")
local test_helpers = require("tests.helpers")

describe("coerce.conversion", function()
	describe("coerce", function()
		it("exits early if select fails", function()
			local transform_called = false
			local cb_args = {}

			cc.coerce(function(cb)
				cb("error")
			end, function()
				transform_called = true
			end, function(v)
				return v
			end, function(arg)
				table.insert(cb_args, arg)
			end)

			assert.is.False(transform_called)
			assert.are.same({ "error" }, cb_args)
		end)
	end)

	describe("coerce_current_word", function()
		it("coerces the current word", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })
			vim.api.nvim_win_set_cursor(0, { 1, 8 })

			require("coop").spawn(cc.coerce_current_word, transformer.transform_local, function()
				return "Bob"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
			assert.are.same({ "Hello, Bob!" }, lines)

			vim.api.nvim_buf_delete(buf, { force = true })
		end)
	end)
end)
