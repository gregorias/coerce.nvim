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

-- Save Luacov stats manually, because Luacov'v hooks don't run properly under `nvim -l`.
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
		local luacov_runner = package.loaded["luacov.runner"]
    if luacov_runner then
      luacov_runner.save_stats()
    end
  end
})
