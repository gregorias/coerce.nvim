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

	describe("shallow_merge", function()
		it("returns empty table without args", function()
			assert.are.same({}, ctable.shallow_merge())
		end)

		it("keep later value", function()
			assert.are.same(
				{ a = 1, b = 2, c = 2,  d = 3 },
				ctable.shallow_merge({ a = 1, b = 1 }, { b = 2, c = 2 }, { d = 3 })
			)
		end)
	end)
end)
