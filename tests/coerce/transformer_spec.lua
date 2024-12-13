local transformer = require("coerce.transformer")
local region = require("coerce.region")
local fake_lsp_server_m = require("tests.fake_lsp_server")
local test_helpers = require("tests.helpers")

describe("coerce.transformer", function()
	describe("transform_local", function()
		it("converts text", function()
			local buf = test_helpers.create_buf({ "Hello, world!" })

			transformer.transform_local({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 7,
				end_row = 1,
				end_col = 12,
			}, function()
				return "Albert"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
			assert.are.same({ "Hello, Albert!" }, lines)
		end)
	end)

	describe("transform_lsp_rename", function()
		local buf = 0

		before_each(function()
			buf = test_helpers.create_buf({ "foo", "local foo" })
			-- LSP rename only works on named buffers.
			vim.api.nvim_buf_set_name(buf, "test.lua")
		end)

		after_each(function()
			vim.api.nvim_buf_delete(buf, { force = true })
		end)

		it("Returns false and does nothing with no supporting LSP server", function()
			local result = transformer.transform_lsp_rename({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 0,
				end_row = 1,
				end_col = 3,
			}, function()
				return "bar"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
			assert.are.same({ "foo", "local foo" }, lines)
			assert.is.False(result)
		end)

		it("renames with LSP", function()
			-- Setup LSP
			local lsp_server = fake_lsp_server_m.server()
			lsp_server.stub_rename("foo", {
				{ line = 0, character = 0 },
				{ line = 1, character = 6 },
			})
			local client_id = vim.lsp.start({
				name = "fake",
				cmd = function(ds)
					return lsp_server(ds)
				end,
			}, { bufnr = buf })

			-- Make the call
			local result = false
			require("coop").spawn(function()
				result = transformer.transform_lsp_rename({
					mode = region.modes.CHAR,
					start_row = 0,
					start_col = 0,
					end_row = 1,
					end_col = 3,
				}, function()
					return "bar"
				end)
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
			assert.are.same({ "bar", "local bar" }, lines)
			assert.is.True(result)

			vim.lsp.get_client_by_id(client_id).stop(true)
		end)
	end)

	describe("transform_lsp_rename_with_local_failover", function()
		local buf

		before_each(function()
			buf = test_helpers.create_buf({ "foo", "local foo" })
			-- LSP rename only works on named buffers.
			vim.api.nvim_buf_set_name(buf, "test.lua")
		end)

		after_each(function()
			vim.api.nvim_buf_delete(buf, { force = true })
		end)

		it("uses the failover when LSP rename is not available", function()
			transformer.transform_lsp_rename_with_local_failover({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 0,
				end_row = 1,
				end_col = 3,
			}, function()
				return "bar"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
			assert.are.same({ "bar", "local foo" }, lines)
		end)

		it("uses the failover when LSP rename fails", function()
			local lsp_server = fake_lsp_server_m.server()
			lsp_server.stub_rename_error()
			local client_id = vim.lsp.start({
				name = "transformer-spec-lsp-rename-fail",
				cmd = function(ds)
					return lsp_server(ds)
				end,
			}, { bufnr = buf })

			require("coop").spawn(function()
				transformer.transform_lsp_rename_with_local_failover({
					mode = region.modes.CHAR,
					start_row = 0,
					start_col = 0,
					end_row = 1,
					end_col = 3,
				}, function()
					return "bar"
				end)
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
			assert.are.same({ "bar", "local foo" }, lines)

			vim.lsp.get_client_by_id(client_id).stop(true)
		end)

		it("uses LSP rename", function()
			local lsp_server = fake_lsp_server_m.server()
			lsp_server.stub_rename("foo", {
				{ line = 0, character = 0 },
				{ line = 1, character = 6 },
			})
			local client_id = vim.lsp.start({
				name = "fake",
				cmd = function(ds)
					return lsp_server(ds)
				end,
			}, { bufnr = buf })

			require("coop").spawn(function()
				transformer.transform_lsp_rename_with_local_failover({
					mode = region.modes.CHAR,
					start_row = 0,
					start_col = 0,
					end_row = 1,
					end_col = 3,
				}, function()
					return "bar"
				end)
			end)

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, true)
			assert.are.same({ "bar", "local bar" }, lines)

			vim.lsp.get_client_by_id(client_id).stop(true)
		end)

		it("only tries LSP rename on the buffer it’s connected to", function()
			local buf_nolsp = test_helpers.create_buf({ "foo", "local foo" })
			-- LSP rename only works on named buffers.
			vim.api.nvim_buf_set_name(buf_nolsp, "test-nolsp.lua")

			local lsp_server = fake_lsp_server_m.server()
			lsp_server.stub_rename("foo", {
				{ line = 0, character = 0 },
				{ line = 1, character = 6 },
			})
			local client_id = vim.lsp.start({
				name = "fake",
				cmd = function(ds)
					return lsp_server(ds)
				end,
			}, { bufnr = buf })

			vim.api.nvim_win_set_buf(0, buf_nolsp)
			vim.api.nvim_win_set_cursor(0, { 1, 0 })

			transformer.transform_lsp_rename_with_local_failover({
				mode = region.modes.CHAR,
				start_row = 0,
				start_col = 0,
				end_row = 1,
				end_col = 3,
			}, function()
				return "bar"
			end)

			local lines = vim.api.nvim_buf_get_lines(buf_nolsp, 0, 2, true)
			assert.are.same({ "bar", "local foo" }, lines)

			vim.lsp.get_client_by_id(client_id).stop(true)

			vim.api.nvim_buf_delete(buf_nolsp, { force = true })
		end)
	end)
end)
