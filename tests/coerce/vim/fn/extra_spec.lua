local extra = require("coerce.vim.fn.extra")
local test_helpers = require("tests.helpers")

describe("coerce.vim.fn.extra", function()
	describe("getpos", function()
		it("gets the current cursor position", function()
			test_helpers.create_buf({ "Hello, world!", "I am Greg.", "ASDSAD" })
			vim.api.nvim_win_set_cursor(0, { 1, 0 })

			local curpos = extra.getpos(".")

			assert.are.same({ 0, 0 }, curpos)
		end)
	end)
end)
