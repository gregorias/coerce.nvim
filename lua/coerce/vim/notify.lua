---Service provider for the `vim.notify` function.
---
---Enables mocking.
return {
	notify = function(...)
		-- We call `vim.notify` lazily, so that we don’t bind vim.notify during the plugin’s setup.
		-- The user may modify `vim.notify` later.
		return vim.notify(...)
	end,
}
