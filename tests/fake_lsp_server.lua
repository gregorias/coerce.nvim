--- A fake LSP server that can be used to test LSP-related functionality.
local M = {}

--- Returns an LSP server implementation.
---
---@param dispatchers table? Methods that allow the server to interact with the client.
---@return table srv The server object.
function M.server(dispatchers)
	dispatchers = dispatchers or {
		on_exit = function(_, _)
			-- Default implementation does nothing.
		end,
	}
	local closing = false
	local srv = {}
	local mt = {}

	-- With this call, it’s possible to interact with the server, e.g., set up new handlers.
	mt.__call = function(_, new_dispatchers)
		dispatchers = new_dispatchers
		return srv
	end
	setmetatable(srv, mt)

	--- This method is called each time the client makes a request to the server
	---
	--- To learn more about what method names are available and the structure of
	--- the payloads, read the specification:
	--- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/.
	---
	---@param method string the LSP method name
	---@param params table the payload that the LSP client sends
	---@param callback function A function which takes two parameters: `err` and `result`.
	---                         The callback must be called to send a response to the client.
	---@return boolean, number
	function srv.request(method, params, callback)
		if method == "initialize" then
			callback(nil, { capabilities = {
				renameProvider = true,
			} })
		elseif method == "shutdown" then
			callback(nil, nil)
		elseif method == "textDocument/rename" then
			srv.rename(params, callback)
		end
		return true, 1
	end

	-- This method is called each time the client sends a notification to the server
	-- The difference between `request` and `notify` is that notifications don’t
	-- expect a response.
	function srv.notify(method, _)
		if method == "exit" then
			dispatchers.on_exit(0, 15)
		end
	end

	--- Indicates if the client is shutting down
	function srv.is_closing()
		return closing
	end

	--- Callend when the client wants to terminate the process
	function srv.terminate()
		closing = true
	end

	-- The default textDocument/rename handler that does nothing.
	function srv.rename(_, _) end

	local function get_rename_workspace_edit(uri, oldText, oldTextPositions, newText)
		local text_edits = {}
		for _, oldTextPosition in ipairs(oldTextPositions) do
			table.insert(text_edits, {
				newText = newText,
				range = {
					start = { line = oldTextPosition.line, character = oldTextPosition.character },
					["end"] = {
						line = oldTextPosition.line,
						character = oldTextPosition.character + string.len(oldText),
					},
				},
			})
		end
		return {
			changes = {
				[uri] = text_edits,
			},
		}
	end

	--- Sets up a stub for the rename method that always returns the same result.
	---
	---@param oldText string The text that will be replaced.
	---@param oldTextPositions table The positions of the old text in the document.
	function srv.stub_rename(oldText, oldTextPositions)
		srv.rename = function(params, callback)
			local uri = params.textDocument.uri
			local newText = params.newName
			callback(nil, get_rename_workspace_edit(uri, oldText, oldTextPositions, newText))
		end
	end

	-- Sets up a stub for the rename method that always returns an internal error.
	function srv.stub_rename_error()
		srv.rename = function(_, callback)
			callback({
				code = -32603,
				message = "Internal error",
			}, nil)
		end
	end

	return srv
end

return M
