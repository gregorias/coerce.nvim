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
end)
