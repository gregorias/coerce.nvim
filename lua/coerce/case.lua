--- A module for case conversion.
-- @module coerce.case
local M = {}

local cs = require("coerce.string")

--- Converts a string into a numerical contraction.
--
--@param str The string to convert.
--@return The numerical contraction.
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

--- Splits a word into its parts.
--
-- Using ”keyword” instead of “word”, because in this context, things like like
-- “kebab-case” are not words.
--
--@tparam string str The word to split.
--@treturn table The parts of the word.
M.split_keyword = function(str)
	local grapheme_list = cs.str2graphemelist(str)
	if #grapheme_list <= 2 then
		return { str }
	end

	local words = {}
	local recognized_separators = {
		["-"] = true,
		["_"] = true,
		["."] = true,
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
		for i = 1, #grapheme_list, 1 do
			if cs.is_upper(grapheme_list[i]) then
				if word ~= "" then
					table.insert(words, word)
				end
				word = grapheme_list[i]
			else
				word = word .. grapheme_list[i]
			end
		end
		if word ~= "" then
			table.insert(words, word)
		end
	end

	words = vim.tbl_map(vim.fn.tolower, words)

	return words
end

return M
