--- A standalone module health checks.
local M = {}

--- Checks Coerce's health.
---
---@return nil
M.check = function()
	vim.health.start("Coerce")
	local coop_status = pcall(require, "coop")
	if coop_status then
		vim.health.ok("Coop found.")
	else
		vim.health.error(
			"Coop not found.",
			"Coerce requires gregorias/coop.nvim to work. Add Coop to your plugins."
		)
	end
	local which_key_status = pcall(require, "which-key")
	if which_key_status then
		vim.health.ok("Which Key found.")
	else
		vim.health.warn(
			"Which Key not found.",
			"Coerce can use Which Key to show hints. Consider adding Which Key."
		)
	end
end

return M
