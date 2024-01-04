local co = require("coerce.operator")
local test_helpers = require("tests.helpers")

describe("coerce.operator", function()
	describe("operator", function()
		it("executes the callback", function()
			test_helpers.create_buf({ "Hello, world!" })

			local mark = "unmarked"
			co.operator(function()
				mark = "marked"
			end)
			vim.api.nvim_feedkeys("iw", "x", false)

			assert.are.same("marked", mark)
		end)
	end)
end)
