local cvim = require("coerce.vim")
local region = require("coerce.region")
local test_helpers = require("tests.helpers")

describe("coerce.vim.api", function()
	describe("nvim_buf_get_mark", function()
		it("gets a zero-indexed mark", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })
			vim.api.nvim_buf_set_mark(buf, "a", 1, 8, {})

			local pos = cvim.api.nvim_buf_get_mark(buf, "a")
			assert.are.same({ 0, 8 }, pos)
		end)
	end)
	describe("nvim_buf_get_text", function()
		it("gets text from a single line", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })

			local fetched_text = cvim.api.nvim_buf_get_text(buf, {
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 1,
				end_row = 1,
				end_col = 5,
			})
			assert.are.same({ "ello" }, fetched_text)
		end)

		it("gets text from a single line", function()
			local buf = test_helpers.create_buf({
				"local M = {}",
				"",
				'local COERCE_PREFIX = "cr"',
				'local CHANGE_CASE_PREFIX = "gc"',
			})

			local fetched_text = cvim.api.nvim_buf_get_text(buf, {
				mode = region.modes.CHAR,
				start_row = 2,
				start_col = 6,
				end_row = 3,
				end_col = 19,
			})
			assert.are.same({ "COERCE_PREFIX" }, fetched_text)
		end)

		it("gets text from multiple lines", function()
			local buf = test_helpers.create_buf({ "Hello, world!", "I am mister bombastic." })

			local fetched_text = cvim.api.nvim_buf_get_text(buf, {
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 1,
				end_row = 2,
				end_col = 5,
			})
			assert.are.same({ "ello, world!", "I am " }, fetched_text)
		end)
	end)
end)
