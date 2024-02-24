local cc = require("coerce.conversion")
local transformer = require("coerce.transformer")
local cco = require("coerce.coroutine")
local test_helpers = require("tests.helpers")

describe("coerce.conversion", function()
	describe("coerce_current_word", function()
		it("coerces the current word", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })
			vim.api.nvim_win_set_cursor(0, { 1, 8 })

			cco.fire_and_forget(cc.coerce_current_word, transformer.transform_local, function()
				return "Bob"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
			assert.are.same({ "Hello, Bob!" }, lines)

			vim.api.nvim_buf_delete(buf, { force = true })
		end)
	end)
end)
