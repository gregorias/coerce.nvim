local cc = require("coerce.case")

describe("coerce.case", function()
	describe("to_camel_case", function()
		it("converts to camel case", function()
			assert.are.same("ąbęÓcki", cc.to_camel_case("ąbę-ócki"))
		end)
	end)
	describe("to_dot_case", function()
		it("converts to dot case", function()
			assert.are.same("ąbę.ócki", cc.to_dot_case("ąbę-ócki"))
		end)
	end)
	describe("to_kebab_case", function()
		it("converts to kebab case", function()
			assert.are.same("ąbę-ócki", cc.to_kebab_case("ąbęÓcki"))
		end)
	end)
	describe("to_pascal_case", function()
		it("converts to pascal case", function()
			assert.are.same("ĄbęÓcki", cc.to_pascal_case("ąbęÓcki"))
		end)
	end)
	describe("to_snake_case", function()
		it("converts to pascal case", function()
			assert.are.same("ąbę_ócki", cc.to_snake_case("ąbęÓcki"))
		end)
	end)
	describe("to_upper_case", function()
		it("converts to upper case", function()
			assert.are.same("ĄBĘ_ÓCKI", cc.to_upper_case("ąbęÓcki"))
		end)
	end)
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
	describe("to_path_case", function()
		it("converts to path case", function()
			assert.are.same("ąbę/ócki", cc.to_path_case("ąbęÓcki"))
		end)
	end)
	describe("to_space_case", function()
		it("converts to space case", function()
			assert.are.same("ąbę ócki", cc.to_space_case("ąbęÓcki"))
		end)
	end)
	describe("split_keyword", function()
		local split_keyword = cc.split_keyword
		it("split keywords", function()
			assert.are.same({ "hello" }, split_keyword("Hello"))
			assert.are.same({ "kebab", "case" }, split_keyword("kebab-case"))
			assert.are.same({ "snake", "case" }, split_keyword("snake_case"))
			assert.are.same({ "dot", "case" }, split_keyword("dot.case"))
			assert.are.same({ "upper", "case" }, split_keyword("UPPER_CASE"))
			assert.are.same({ "camel", "case" }, split_keyword("camelCase"))
			assert.are.same({ "pascal", "case" }, split_keyword("PascalCase"))
			assert.are.same({ "path", "case" }, split_keyword("path/case"))
			assert.are.same({ "space", "case" }, split_keyword("space case"))
		end)

		it("treats upper-case-only keywords as singletons", function()
			assert.are.same({ "cia" }, split_keyword("CIA"))
		end)
	end)
end)
