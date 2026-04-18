-- Custom String methods

local select = select
local tostring = tostring
local string_gsub = string.gsub
local string_sub = string.sub
local string_match = string.match

function string.StartsWith(str, text)
	return string_sub(str, 1, #text) == text
end

function string.EndsWith(str, text)
	return text == "" or string_sub(str, -#text) == text
end

function string.Trim(str)
	-- The parentheses force Lua to discard extra return values if the API ever changes
	return (string_match(str, "^%s*(.-)%s*$"))
end

function string.FormatArgs(str, ...)
	str = str or ""

	local args = { ... }
	for i = 1, select("#", ...) do -- Avoid using #args to support trailing nils
		str = string_gsub(str, "{" .. i .. "}", tostring(args[i]))
	end

	return str
end

function string.ToTable(str)
	if (not str) then return {} end

	local tbl = {}

	for i = 1, #str do
		tbl[i] = string_sub(str, i, i)
	end

	return tbl
end
