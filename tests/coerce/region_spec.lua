local region_m = require("coerce.region")

describe("coerce.region", function()
	describe("region", function()
		it("constructs a line region", function()
			local lines = region_m.region(region_m.modes.LINE, { 1, 10 }, { 4, 20 })
			assert.are.same({
				mode = region_m.modes.LINE,
				start_row = 1,
				end_row = 5,
			}, lines)
		end)
	end)
end)
