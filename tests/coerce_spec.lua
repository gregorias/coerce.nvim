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

	it("displays an error for a multiline selection in visual mode", function()
		local buf = test_helpers.create_buf({ "myCase", "yourCase" })
		local notification = nil

		c.setup({
			notify = function(message, level)
				notification = { message = message, level = level }
			end,
		})
		-- `vj` selects 2 lines
		-- `cru` runs the upper case coersion
		test_helpers.execute_keys("Vjcru", "x")

		local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
		-- Nothing has changed.
		assert.are.same({ "myCase", "yourCase" }, lines)
		-- A notification has been displayed.
		assert.are.same(
			{ message = "2 lines selected. Coerce supports only single-line visual selections.", level = "error" },
			notification
		)
	end)
end)
