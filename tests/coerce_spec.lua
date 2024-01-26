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
		-- `cru` runs upper case coercion
		test_helpers.execute_keys("vecru", "x")

		local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
		assert.are.same({ "MY_CASE" }, lines)
	end)

	it("works with motion selection", function()
		local buf = test_helpers.create_buf({ "myCase" })
		c.setup({})
		-- `gcr` starts the operator pending mode
		-- `u` select upper case coercion
		-- `e` select the keyword
		test_helpers.execute_keys("gcrue", "x")

		local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
		assert.are.same({ "MY_CASE" }, lines)
	end)

	it("works with motion selection even with a user-defined g@ keymap", function()
		local buf = test_helpers.create_buf({ "myCase" })
		vim.keymap.set("n", "g@", '<cmd>echo "Pressed g@"<cr>')
		c.setup({})
		-- `gcr` starts the operator pending mode
		-- `u` select upper case coercion
		-- `e` select the keyword
		test_helpers.execute_keys("gcrue", "x")

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

	it("coerces current word even with conflicting keymaps", function()
		local buf = test_helpers.create_buf({ "myCase" })
		vim.keymap.set("o", "i", '<cmd>echo "Pressed i"<cr>')
		vim.keymap.set("o", "w", '<cmd>echo "Pressed w"<cr>')
		c.setup({})
		-- `cru` runs upper case coercion
		test_helpers.execute_keys("cru", "x")

		local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
		assert.are.same({ "MY_CASE" }, lines)
	end)
end)
