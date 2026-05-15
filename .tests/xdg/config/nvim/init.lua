vim.pack.add({
	{
		src = "https://gitlab.com/HiPhish/yo-dawg.nvim.git",
		version = "master",
	},
	{
		src = "https://github.com/gregorias/coop.nvim.git",
		version = "main",
	},
})
vim.opt.runtimepath:append(".")
-- Initialize Luacov.
require("luacov")
local luacov_runner = require("luacov.runner")

-- Save Luacov stats manually, because Luacov'v hooks don't run properly under `nvim -l`.
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		luacov_runner.save_stats()
	end,
})
