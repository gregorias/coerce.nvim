local selector = require("coerce.selector")
local cco = require("coerce.coroutine")
local region = require("coerce.region")
local test_helpers = require("tests.helpers")

describe("coerce.selector", function()
	describe("select_with_motion", function()
		it("select the word", function()
			test_helpers.create_buf({ "Hello, world!" })

			local selected_region = nil
			cco.fire_and_forget(function()
				selected_region = selector.select_with_motion()
			end)
			test_helpers.execute_keys("e", "x")

			assert.are.same(region.region(region.modes.CHAR, { 0, 0 }, { 0, 4 }), selected_region)
		end)
	end)
end)
