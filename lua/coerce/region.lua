--- A region module.
--
-- A region is an area of text in a buffer. There are three types of regions:
--
-- - char represents a contiguous range of characters that can pass through zero or more rows.
-- - line represents a contiguous range of rows.
-- - block represents a rectangular block of text.
--
-- All ranges are:
--
-- - zero-indexed
-- - start-inclusive
-- - end-exclusive
--
-- @module coerce.region
local M = {}

--- Available region modes.
--
-- For now, we only support the char mode.
M.modes = {
	CHAR = "char",
	LINE = "line",
	BLOCK = "block",
}

--- An example empty char region.
M.empty_char_region = {
	mode = M.modes.CHAR,
	start_row = 0,
	start_col = 0,
	end_row = 0,
	end_col = 0,
}

--- An example empty line region.
M.empty_line_region = {
	mode = M.modes.LINE,
	start_row = 0,
	end_row = 0,
}

--- Gets the lines selected by a region.
--
--@tparam Region region The region to get the lines from.
--@return number The number of lines in the region.
M.lines = function(region)
	return region.end_row - region.start_row
end

--- Creates a region between two points.
--
-- Everything should be zero-indexed.
--
--@tparam RegionMode mode The mode.
--@tparam table The inclusive start.
--@tparam table The inclusive end.
--@treturn Region The created region.
M.region = function(mode, s, e)
	-- Make sure we we change start and end if end is higher than start.
	-- This happens when we select from bottom to top or from right to left.
	local start_row = math.min(s[1], e[1])
	local start_col = math.min(s[2], e[2])
	local end_row = math.max(s[1], e[1]) + 1
	local end_col_1 = math.min(s[2], vim.fn.getline(s[1] + 1):len()) + 1
	local end_col_2 = math.min(e[2], vim.fn.getline(e[1] + 1):len()) + 1
	local end_col = math.max(end_col_1, end_col_2)

	if mode == M.modes.LINE then
		return {
			mode = mode,
			start_row = start_row,
			end_row = end_row,
		}
	else
		return {
			mode = mode,
			start_row = start_row,
			start_col = start_col,
			end_row = end_row,
			end_col = end_col,
		}
	end
end

return M
