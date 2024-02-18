--- A fake LSP server that can be used to test LSP-related functionality.
local M = {}

--- Return an LSP server implementation.
--
-- @tparam table dispatchers A couple methods that allow the server to interact with the client.
function M.server(dispatchers)
	local closing = false
	local srv = {}
	local mt = {}

	-- With this call, it’s possible to interact with the server, e.g., set up new handlers.
	mt.__call = function(new_dispatchers)
		dispatchers = new_dispatchers
		return srv
	end
	setmetatable(srv, mt)

	-- This method is called each time the client makes a request to the server
	--
	-- To learn more about what method names are available and the structure of
	-- the payloads, read the specification:
	-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
	--
	-- @tparam string method the LSP method name
	-- @tparam table params the payload that the LSP client sends
	-- @tparam function callback A function which takes two parameters: `err` and `result`.
	--                           The callback must be called to send a response to the client
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
	---@diagnostic disable-next-line: unused-local
	function srv.notify(method, _params)
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
	---@diagnostic disable-next-line: unused-local
	function srv.rename(params, callback) end

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

	-- Sets up a stub for the rename method that always returns the same result.
	--
	-- @param oldText The text that will be replaced.
	-- @param oldTextPositions The positions of the old text in the document.
	function srv.stub_rename(oldText, oldTextPositions)
		srv.rename = function(params, callback)
			local uri = params.textDocument.uri
			local newText = params.newName
			callback(nil, get_rename_workspace_edit(uri, oldText, oldTextPositions, newText))
		end
	end

	return srv
end

return M
