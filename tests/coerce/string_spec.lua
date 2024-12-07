local coerce_string = require("coerce.string")

describe("coerce.string", function()
	describe("is_unicase", function()
		it("treats punctuation as unicase.", function()
			assert.True(coerce_string.is_unicase("-,:"))
		end)
		it("treats numbers as unicase.", function()
			assert.True(coerce_string.is_unicase("9123"))
		end)
		it("treats kanji as unicase.", function()
			assert.True(coerce_string.is_unicase("あいうえお"))
		end)
		it("treats alphabet as not unicase.", function()
			assert.False(coerce_string.is_unicase("ą"))
			assert.False(coerce_string.is_unicase("Ą"))
			assert.False(coerce_string.is_unicase("z"))
		end)
	end)
	describe("is_upper|is_lower", function()
		it("should reliably check for upper caseness.", function()
			assert.True(coerce_string.is_upper("A"))
			assert.True(coerce_string.is_upper("Ą"))
			assert.False(coerce_string.is_upper("a"))
			assert.False(coerce_string.is_upper("ą"))
		end)

		it("should handle multi-codepoint graphemes.", function()
			local char2nr = vim.fn.char2nr
			local list2str = vim.fn.list2str

			local some_a = list2str({ char2nr("a"), 0x301 })
			assert.False(coerce_string.is_unicase(some_a))
			assert.False(coerce_string.is_upper(some_a))
			assert.True(coerce_string.is_lower(some_a))
		end)

		it("should mark unicase characters as neither lower nor upper case.", function()
			assert.False(coerce_string.is_upper("."))
			assert.False(coerce_string.is_lower("."))
		end)
	end)
	describe("str2graphemelist", function()
		it("splits a Unicode string", function()
			local char2nr = vim.fn.char2nr
			local list2str = vim.fn.list2str

			assert.are.same({ "a", "b", "c" }, coerce_string.str2graphemelist("abc"))
			assert.are.same({ "ą", "b", "c" }, coerce_string.str2graphemelist("ąbc"))
			local some_a = list2str({ char2nr("a"), 0x301 })
			assert.are.same(
				{ "ą", "b", some_a, "c" },
				coerce_string.str2graphemelist("ąb" .. some_a .. "c")
			)
		end)
	end)
end)
