--- Extra vim.lsp utilities.
--
--@module coerce.vim.lsp
local M = {}

local cb_to_co = require("coop.coroutine-utils").cb_to_co

local pack = function(...)
	-- selene: allow(mixed_table)
	return { n = select("#", ...), ... }
end

--- Returns whether any LSP client supports the rename method.
--
-- This function only considers clients connected to the current buffer. We are not interested in
-- clients that might be somewhere but are meaningless for the purposes of the rename.
function M.does_any_client_support_rename()
	local clients = vim.lsp.get_clients()
	for _, client in pairs(clients) do
		if vim.lsp.buf_is_attached(0, client.id) and client.supports_method("textDocument/rename") then
			return true
		end
	end
	return false
end

--- Sends a request to the LSP server.
---
--- Wraps `client.request` into a fire-and-forget coroutine function to make its use more ergonomical.
---
---@tparam vim.lsp.Client client
---@tparam string method
---@tparam table? params
---@tparam integer? bufnr
---@return table vim.lsp.Handler's signature
function M.client_request(client, method, params, bufnr)
	return cb_to_co(function(cb)
		client.request(method, params, function(...)
			cb(...)
		end, bufnr)
	end)()
end

--- Renames all references to the symbol under the cursor.
---
--- This is a fire-and-forget coroutine function.
---
--- This is a tweaked copy of Neovim’s implementation at
--- https://github.com/neovim/neovim/blob/efa45832ea02e777ce3f5556ef3cd959c164ec24/runtime/lua/vim/lsp/buf.lua#L298.
---
---@tparam string new_name
---@treturn boolean Whether any client has succeeded in renaming.
function M.rename(new_name)
	local api = vim.api
	local util = require("vim.lsp.util")
	local ms = require("vim.lsp.protocol").Methods

	local bufnr = api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({
		bufnr = bufnr,
		name = nil,
		-- Clients must at least support rename, prepareRename is optional
		method = ms.textDocument_rename,
	})
	local has_any_success = false

	if #clients == 0 then
		return has_any_success
	end

	local win = api.nvim_get_current_win()

	--- @param name string
	local function rename(client, name)
		local params = util.make_position_params(win, client.offset_encoding)
		params.newName = name
		local handler = client.handlers[ms.textDocument_rename] or vim.lsp.handlers[ms.textDocument_rename]
		local result = pack(M.client_request(client, ms.textDocument_rename, params, bufnr))
		if not result[1] then
			has_any_success = true
		end
		handler(unpack(result, 1, result.n))
	end

	for idx, client in ipairs(clients) do
		if client.supports_method(ms.textDocument_prepareRename) then
			local params = util.make_position_params(win, client.offset_encoding)
			local err, result = M.client_request(client, ms.textDocument_prepareRename, params, bufnr)
			if err or result == nil then
				if idx < #clients then
					-- continue
					do
					end
				else
					local msg = err and ("Error on prepareRename: " .. (err.message or "")) or "Nothing to rename"
					vim.notify(msg, vim.log.levels.INFO)
				end
			else
				rename(client, new_name)
			end
		else
			assert(client.supports_method(ms.textDocument_rename), "Client must support textDocument/rename")
			rename(client, new_name)
		end
	end

	return has_any_success
end

return M
