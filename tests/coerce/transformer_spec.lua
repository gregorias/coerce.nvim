local transformer = require("coerce.transformer")
local region = require("coerce.region")
local test_helpers = require("tests.helpers")

describe("coerce.transformer", function()
	describe("transform_local", function()
		it("converts text", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })

			transformer.transform_local({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 7,
				end_row = 1,
				end_col = 12,
			}, function()
				return "Albert"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
			assert.are.same({ "Hello, Albert!" }, lines)
		end)
	end)
end)
