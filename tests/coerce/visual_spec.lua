local visual = require("coerce.visual")
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
end)
