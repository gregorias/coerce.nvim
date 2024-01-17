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

return M
