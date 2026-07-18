--[[ Custom String methods --]]

function string.StartsWith(str, text)
	return str:sub(1, #text) == text
end

function string.EndsWith(str, text)
	return text == "" or str:sub(-#text) == text
end

function string.Trim(str)
	return (str:match("^%s*(.-)%s*$"))
end

function string.FormatArgs(str, ...)
	str = str or ""

	for i, arg in ipairs { ... } do
		str = str:gsub("{" .. i .. "}", tostring(arg))
	end

	return str
end

function string.ToTable(str)
	if (not str) then return {} end

	local tbl = {}

	for i = 1, #str do
		tbl[i] = str:sub(i, i)
	end

	return tbl
end

local escaped_pattern_characters = {
    ["("] = "%(",
	[")"] = "%)",
	["["] = "%[",
	["]"] = "%]",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.SafePattern(str)
    return (string.gsub(str, ".", escaped_pattern_characters))
end

function string.Split(str, delimiter, is_pattern)
    if not delimiter or #delimiter == 0 then
        return string.ToTable(str)
    end

    local result = {}
    local pos = 1

    while true do
        local first, last = string.find(str, delimiter, pos, not is_pattern)
        if not first then
            break
        end

		if last < pos then
            return error("delimiter pattern matched an empty string", 2)
        end

        result[#result + 1] = string.sub(str, pos, first - 1)

        pos = last + 1
    end

    result[#result + 1] = string.sub(str, pos)

    return result
end
