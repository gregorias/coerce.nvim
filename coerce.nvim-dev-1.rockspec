rockspec_format = "3.0"
package = "coerce.nvim"
version = "dev-1"

source = {
	url = "git+https://github.com/gregorias/coerce.nvim",
}

description = {
	summary = "A Neovim plugin for changing keyword case.",
	homepage = "https://github.com/gregorias/coerce.nvim",
	license = "GPL-3.0",
}

dependencies = {
	"lua >= 5.1",
}

test_dependencies = {
	"busted",
	"luacov",
}

build = {
	type = "builtin",
	modules = {
		coerce = "lua/coerce.lua",
		["coerce.case"] = "lua/coerce/case.lua",
		["coerce.conversion"] = "lua/coerce/conversion.lua",
		["coerce.keymap"] = "lua/coerce/keymap.lua",
		["coerce.operator"] = "lua/coerce/operator.lua",
		["coerce.region"] = "lua/coerce/region.lua",
		["coerce.selector"] = "lua/coerce/selector.lua",
		["coerce.string"] = "lua/coerce/string.lua",
		["coerce.table"] = "lua/coerce/table.lua",
		["coerce.transformer"] = "lua/coerce/transformer.lua",
		["coerce.vim"] = "lua/coerce/vim.lua",
		["coerce.vim.api"] = "lua/coerce/vim/api.lua",
		["coerce.vim.fn"] = "lua/coerce/vim/fn.lua",
		["coerce.vim.lsp"] = "lua/coerce/vim/lsp.lua",
		["coerce.visual"] = "lua/coerce/visual.lua",
	},
}
