local c = require("coerce")
local test_helpers = require("tests.helpers")
describe("coerce", function()
	describe("register", function()
		it("registers a new case", function()
			local buf = test_helpers.create_buf({ "myCase" })
			c.setup({})
			c.register({
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
end)
