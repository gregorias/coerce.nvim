local visual = require("coerce.visual")
local region = require("coerce.region")
local test_helpers = require("tests.helpers")

describe("coerce.visual", function()
	describe("get_current_visual_mode", function()
		it("gets the correct mode", function()
			test_helpers.create_buf({ "hello world" })

			test_helpers.execute_keys("v", "x")
			assert.are.same(visual.visual_mode.INLINE, visual.get_current_visual_mode())

			test_helpers.execute_keys("<esc>V", "x")
			assert.are.same(visual.visual_mode.LINE, visual.get_current_visual_mode())

			test_helpers.execute_keys("<esc><C-V>", "x")
			assert.are.same(visual.visual_mode.BLOCK, visual.get_current_visual_mode())
		end)
	end)

	describe("get_current_visual_selection", function()
		it("gets current inline selection", function()
			test_helpers.create_buf({ "hello world" })
			test_helpers.execute_keys("v2l", "x")

			local selection = visual.get_current_visual_selection()

			assert.are.same(region.region(region.modes.CHAR, { 0, 0 }, { 0, 2 }), selection)
		end)

		it("gets current line selection", function()
			test_helpers.create_buf({ "hello world" })
			test_helpers.execute_keys("V", "x")

			local selection = visual.get_current_visual_selection()

			assert.are.same({ mode = region.modes.LINE, start_row = 0, end_row = 1 }, selection)
		end)
	end)
end)
