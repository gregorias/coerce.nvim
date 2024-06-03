local ctable = require("coerce.table")

describe("coerce.table", function()
	describe("shift", function()
		it("leaves empty sequence empty", function()
			assert.are.same({}, ctable.shift({}))
		end)

		it("leaves one-element sequence empty", function()
			assert.are.same({}, ctable.shift({ 1 }))
		end)

		it("shifts a multi-element sequence", function()
			assert.are.same({ 2, 3 }, ctable.shift({ 1, 2, 3 }))
		end)
	end)
end)
