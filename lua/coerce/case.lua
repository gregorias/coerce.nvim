--- A module for case conversion.
-- @module coerce.case
local M = {}

local cs = require("coerce.string")

--- Converts a keyword into PascalCase.
---
---@param str string the string to convert
---@return string
M.to_camel_case = function(str)
	local parts = M.split_keyword(str)

	for i = 2, #parts, 1 do
		local part_graphemes = cs.str2graphemelist(parts[i])
		part_graphemes[1] = vim.fn.toupper(part_graphemes[1])
		parts[i] = table.concat(part_graphemes, "")
	end

	return table.concat(parts, "")
end

--- Converts a keyword into dot-case.
---
---@param str string the string to convert
---@return string
M.to_dot_case = function(str)
	local parts = M.split_keyword(str)
	return table.concat(parts, ".")
end

--- Converts a keyword into kebab-case.
---
---@param str string the string to convert
---@return string
M.to_kebab_case = function(str)
	local parts = M.split_keyword(str)
	return table.concat(parts, "-")
end

--- Converts a string into a numerical contraction.
---
---@param str string the string to convert
---@return string str the numerical contraction
M.to_numerical_contraction = function(str)
	local grapheme_list = cs.str2graphemelist(str)
	if #grapheme_list <= 2 then
		return str
	end

	local character_count = 0
	local idx = 2
	while idx <= (#grapheme_list - 1) do
		local grapheme = grapheme_list[idx]
		if vim.fn.charclass(grapheme) == 2 then
			character_count = character_count + 1
		end
		idx = idx + 1
	end

	return grapheme_list[1] .. character_count .. grapheme_list[#grapheme_list]
end

--- Converts a keyword into PascalCase.
---
---@param str string the string to convert
---@return string
M.to_pascal_case = function(str)
	local parts = M.split_keyword(str)

	for i = 1, #parts, 1 do
		local part_graphemes = cs.str2graphemelist(parts[i])
		part_graphemes[1] = vim.fn.toupper(part_graphemes[1])
		parts[i] = table.concat(part_graphemes, "")
	end

	return table.concat(parts, "")
end

--- Converts a keyword into snake_case.
---
---@param str string the string to convert
---@return string
M.to_snake_case = function(str)
	local parts = M.split_keyword(str)
	return table.concat(parts, "_")
end

--- Converts a keyword into snake_case.
---
---@param str string the string to convert
---@return string
M.to_upper_case = function(str)
	local parts = M.split_keyword(str)

	parts = vim.tbl_map(vim.fn.toupper, parts)
	return table.concat(parts, "_")
end

--- Converts a keyword into path/case.
---
---@param str string the string to convert
---@return string
M.to_path_case = function(str)
	local parts = M.split_keyword(str)

	return table.concat(parts, "/")
end

--- Converts a keyword into space case.
---
---@param str string the string to convert
---@return string
M.to_space_case = function(str)
	local parts = M.split_keyword(str)

	return table.concat(parts, " ")
end

--- Splits a word into its parts.
---
--- Using ”keyword” instead of “word”, because in this context, things like like
--- “kebab-case” are not words.
---
---@param str string the string to split
---@return string[] words keyword parts
M.split_keyword = function(str)
	local grapheme_list = cs.str2graphemelist(str)
	if #grapheme_list <= 2 then
		return { str }
	end

	local recognized_separators = {
		["-"] = true,
		["_"] = true,
		["."] = true,
		["/"] = true,
		[" "] = true,
	}
	local found_separator = nil

	local words = {}

	for i = 1, #grapheme_list, 1 do
		if recognized_separators[grapheme_list[i]] then
			found_separator = grapheme_list[i]
			break
		end
	end

	if found_separator then
		local word = ""
		for i = 1, #grapheme_list, 1 do
			if grapheme_list[i] == found_separator then
				table.insert(words, word)
				word = ""
			else
				word = word .. grapheme_list[i]
			end
		end
		if word ~= "" then
			table.insert(words, word)
		end
	else
		-- No separator found. Separate by upper case.
		local word = ""
		local is_last_char_upper = false
		for i = 1, #grapheme_list, 1 do
			local is_upper = cs.is_upper(grapheme_list[i])
			if is_upper and not is_last_char_upper then
				if word ~= "" then
					table.insert(words, word)
				end
				word = grapheme_list[i]
			else
				word = word .. grapheme_list[i]
			end
			is_last_char_upper = is_upper
		end
		if word ~= "" then
			table.insert(words, word)
		end
	end

	words = vim.tbl_map(vim.fn.tolower, words)

	return words
end

return M
