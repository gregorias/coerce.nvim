local c = require("coerce")
local test_helpers = require("tests.helpers")
describe("coerce", function()
	describe("register", function()
		it("registers a new case", function()
			local buf = test_helpers.create_buf({ "myCase" })
			c.setup({})
			c.register_case({
				keymap = "i",
				case = function(str)
					return str:sub(1, 1)
				end,
				description = "initials",
			})
			vim.api.nvim_feedkeys("cri", "x", false)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
			assert.are.same({ "m" }, lines)
		end)
	end)

	it("works in visual mode", function()
		local buf = test_helpers.create_buf({ "myCase" })
		c.setup({})
		-- `ve` selects the keyword
		-- `cru` runs the upper case coersion
		test_helpers.execute_keys("vecru", "x")

		local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
		assert.are.same({ "MY_CASE" }, lines)
	end)
end)
