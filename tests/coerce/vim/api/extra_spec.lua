local vae = require("coerce.vim.api.extra")
local region = require("coerce.region")

describe("coerce.vim.api.extra", function()
	describe("nvim_buf_get_text", function()
		it("gets text from a single line", function()
			local buf = vim.api.nvim_create_buf(--[[listed]] false, --[[scratch]] true)
			vim.api.nvim_buf_set_lines(
				--[[buffer]]
				buf,
				--[[start]]
				0,
				--[[end]]
				-1,
				--[[strict_indexing]]
				true,
				{
					"Hello, world!",
				}
			)

			local fetched_text = vae.nvim_buf_get_text(
			  buf,
				{
					mode = region.modes.CHAR_MODE,
					start_row = 0,
					start_col = 1,
					end_row = 1,
					end_col = 5,
				}
			)
			assert.are.same({"ello"}, fetched_text)
		end)

		it("gets text from multiple lines", function()
			local buf = vim.api.nvim_create_buf(--[[listed]] false, --[[scratch]] true)
			vim.api.nvim_buf_set_lines(
				--[[buffer]]
				buf,
				--[[start]]
				0,
				--[[end]]
				-1,
				--[[strict_indexing]]
				true,
				{
					"Hello, world!",
					"I am mister bombastic."
				}
			)

			local fetched_text = vae.nvim_buf_get_text(
			  buf,
				{
					mode = region.modes.CHAR_MODE,
					start_row = 0,
					start_col = 1,
					end_row = 2,
					end_col = 5,
				}
			)
			assert.are.same({"ello, world!", "I am "}, fetched_text)
		end)
	end)
end)
