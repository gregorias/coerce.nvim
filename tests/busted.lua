#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").busted({
	spec = {
		{ [1] = "gregorias/coop.nvim", lazy = true },
		{ "https://github.com/lunarmodules/luacov" },
	},
	rocks = {
		-- Required for Busted.
		enabled = true,
	},
})

-- Trigger luacov to generate the report.
-- It seems necessary to call this function as it doesn’t trigger automatically.
local luacov_success, runner = pcall(require, "luacov.runner")
if luacov_success and runner.initialized then
	runner.shutdown()
end
