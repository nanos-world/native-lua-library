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
    return string.gsub(str, ".", escaped_pattern_characters)
end

function string.Split(str, delimiter, is_pattern)
    if (not delimiter) or delimiter == "" then
        return string.ToTable(str)
    end

    local cur_i = 1

    local tbl = {}
    for _=1, string.len(str) do
        local start_i, end_i = string.find(str, delimiter, cur_i, not is_pattern)
        if not start_i then break end
        tbl[#tbl+1] = string.sub(str, cur_i, start_i-1)
        cur_i = end_i+1
    end

    tbl[#tbl+1] = string.sub(str, cur_i)

    return tbl
end