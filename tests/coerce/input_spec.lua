local cinput = require("coerce.input")

describe("coerce.input", function()
	describe("get_char", function()
		it("gets a character", function()
			vim.api.nvim_feedkeys("a", "i", true)
			local res = cinput.get_char()
			assert.are.same("a", res)
		end)

		it("returns nil for ⎋", function()
			vim.api.nvim_feedkeys("\27", "i", true)
			local res = cinput.get_char() == nil
			assert.is.True(res)
		end)
	end)
end)
