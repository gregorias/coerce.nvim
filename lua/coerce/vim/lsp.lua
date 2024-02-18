--- Extra vim.lsp utilities.
--
--@module coerce.vim.lsp
local M = {}

--- Returns whether any LSP client supports the rename method.
function M.does_any_client_support_rename()
	local clients = vim.lsp.get_active_clients()
	for _, client in pairs(clients) do
		if client.supports_method("textDocument/rename") then
			return true
		end
	end
	return false
end

return M
