local cvim = require("coerce.vim")
local test_helpers = require("tests.helpers")
local fake_lsp_server_m = require("tests.fake_lsp_server")

describe("coerce.vim.lsp", function()
	describe("does_any_client_support_rename", function()
		it("returns false by default", function()
			test_helpers.create_buf({ "Hello, world!" })

			assert.is.False(cvim.lsp.does_any_client_support_rename())
		end)

		it("returns true when there’s a rename supporting client", function()
			test_helpers.create_buf({ "Hello, world!" })
			local fake_lsp_server = fake_lsp_server_m.server()
			local client_id = vim.lsp.start({
				name = "fake",
				cmd = function(ds)
					return fake_lsp_server(ds)
				end,
			})

			assert.is.True(vim.lsp.get_client_by_id(client_id).supports_method("textDocument/rename"))
			assert.is.True(cvim.lsp.does_any_client_support_rename())
		end)
	end)

	describe("rename", function()
		it("renames a word", function()
			local bufnr = test_helpers.create_buf({ "foo", "local foo" })
			-- LSP rename only works on named buffers.
			vim.api.nvim_buf_set_name(bufnr, "test.lua")
			local lsp_server = fake_lsp_server_m.server()
			lsp_server.stub_rename("foo", {
				{ line = 0, character = 0 },
			})
			local client_id = vim.lsp.start({
				name = "fake",
				cmd = function(ds)
					return lsp_server(ds)
				end,
			}, { bufnr = bufnr })

			local result = false
			require("coop.coroutine-utils").fire_and_forget(function()
				result = cvim.lsp.rename("bar")
			end)

			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)
			assert.is.True(result)
			assert.are.same({ "bar" }, lines)

			vim.lsp.get_client_by_id(client_id).stop(true)
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end)
	end)
end)
