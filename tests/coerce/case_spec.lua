local cc = require("coerce.case")

describe("coerce.case", function()
	describe("to_numerical_contraction", function()
		it("converts a complex Unicode string its numerical contraction", function()
			local char2nr = vim.fn.char2nr
			local list2str = vim.fn.list2str
			local some_a = list2str({ char2nr("a"), 0x301 })
			local weird_string = "ąb" .. some_a .. "c"

			assert.are.same("ą2c", cc.to_numerical_contraction(weird_string))
		end)

		it("converts “accessibility”", function()
			assert.are.same("a11y", cc.to_numerical_contraction("accessibility"))
		end)

		it("converts to A16z", function()
			assert.are.same("A16z", cc.to_numerical_contraction("Andreessen Horowitz"))
		end)
	end)
	describe("split_keyword", function()
		it("split keywords", function()
			assert.are.same({ "hello" }, cc.split_keyword("Hello"))
			assert.are.same({ "kebab", "case" }, cc.split_keyword("kebab-case"))
			assert.are.same({ "snake", "case" }, cc.split_keyword("snake_case"))
			assert.are.same({ "dot", "case" }, cc.split_keyword("dot.case"))
			assert.are.same({ "upper", "case" }, cc.split_keyword("UPPER_CASE"))
			assert.are.same({ "camel", "case" }, cc.split_keyword("camelCase"))
			assert.are.same({ "pascal", "case" }, cc.split_keyword("PascalCase"))
		end)
	end)
end)
