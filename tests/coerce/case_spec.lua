local cc = require("coerce.case")

describe("coerce.case", function()
	describe("to_numeronym", function()
		it("converts strings to numeronyms", function()
			local char2nr = vim.fn.char2nr
			local list2str = vim.fn.list2str
			local some_a = list2str({ char2nr("a"), 0x301 })
			local weird_string = "ąb" .. some_a .. "c"

			assert.are.same("ą2c", cc.to_numeronym(weird_string))
		end)
	end)
end)
