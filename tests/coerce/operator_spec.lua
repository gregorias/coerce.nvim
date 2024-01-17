local co = require("coerce.operator")
local region = require("coerce.region")
local test_helpers = require("tests.helpers")

describe("coerce.operator", function()
	describe("operator_cb", function()
		it("executes the callback", function()
			test_helpers.create_buf({ "Hello, world!" })

			local mark = "unmarked"
			co.operator_cb(function()
				mark = "marked"
			end)
			vim.api.nvim_feedkeys("iw", "x", false)

			assert.are.same("marked", mark)
		end)
	end)

	describe("operator", function()
		it("returns the selected region", function()
			test_helpers.create_buf({ "Hello, world!" })
			local selected_region = co.operator("m", "iw")

			assert.are.same({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 0,
				end_row = 1,
				end_col = 5,
			}, selected_region)
		end)
	end)

	describe("get_selected_region", function()
		it("gets a word selection", function()
			test_helpers.create_buf({
				"Hello, world!",
				"I am Greg.",
			})

			local selected_region = nil
			co.operator_cb(function(mode)
				selected_region = co.get_selected_region(mode)
			end)
			vim.api.nvim_feedkeys("e", "x", false)

			assert.are.same({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 0,
				end_row = 1,
				end_col = 5,
			}, selected_region)
		end)
	end)
end)
