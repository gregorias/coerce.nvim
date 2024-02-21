--- Extra vim.lsp utilities.
--
--@module coerce.vim.lsp
local M = {}

--- Returns whether any LSP client supports the rename method.
--
-- This function only considers clients connected to the current buffer. We are not interested in
-- clients that might be somewhere but are meaningless for the purposes of the rename.
function M.does_any_client_support_rename()
	local clients = vim.lsp.get_active_clients()
	for _, client in pairs(clients) do
		if vim.lsp.buf_is_attached(0, client.id) and client.supports_method("textDocument/rename") then
			return true
		end
	end
	return false
end

return M
