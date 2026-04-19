-- Color

Color = {}
Color.__index = Color

setmetatable(Color, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local tonumber = tonumber
local type = type
local math_ceil = math.ceil
local math_min = math.min
local math_random = math.random
local string_format = string.format
local string_sub = string.sub

function Color.new(r, g, b, a)
	-- Defaults to opaque black color in case arguments are invalid
	r = tonumber(r) or 0
	return setmetatable({
		R = r,
		G = tonumber(g) or r,
		B = tonumber(b) or r,
		A = tonumber(a) or 1
	}, Color)
end

function Color:__add(other)
	-- Color + number
	if (type(other) == "number") then
		return Color(self.R + other, self.G + other, self.B + other, self.A + other)
	end

	-- number + Color
	if (type(self) == "number") then
		return Color(self + other.R, self + other.G, self + other.B, self + other.A)
	end

	-- Assume Color + Color
	return Color(self.R + other.R, self.G + other.G, self.B + other.B, self.A + other.A)
end

function Color:__sub(other)
	-- Color - number
	if (type(other) == "number") then
		return Color(self.R - other, self.G - other, self.B - other, self.A - other)
	end

	-- Assume Color + Color
	return Color(self.R - other.R, self.G - other.G, self.B - other.B, self.A - other.A)
end

function Color:__mul(other)
	-- Color * number
	if (type(other) == "number") then
		return Color(self.R * other, self.G * other, self.B * other, self.A * other)
	end

	-- number * Color
	if (type(self) == "number") then
		return Color(self * other.R, self * other.G, self * other.B, self * other.A)
	end

	-- Assume Color + Color
	return Color(self.R * other.R, self.G * other.G, self.B * other.B, self.A * other.A)
end

function Color:__div(other)
	-- Color / number
	if (type(other) == "number") then
		return Color(self.R / other, self.G / other, self.B / other, self.A / other)
	end

	-- Assume Color / Color
	return Color(self.R / other.R, self.G / other.G, self.B / other.B, self.A / other.A)
end

function Color:__eq(other)
	return self.R == other.R and self.G == other.G and self.B == other.B and self.A == other.A
end

function Color:__tostring()
	return string_format("Color(R = %.3f, G = %.3f, B = %.3f, A = %.3f)", self.R, self.G, self.B, self.A)
end

function Color:ToHex(appends_transparency)
	return appends_transparency
	and string_format(
			"#%.2X%.2X%.2X%.2X",
			math_ceil(self.R * 255),
			math_ceil(self.G * 255),
			math_ceil(self.B * 255),
			math_ceil(self.A * 255)
		)
	or string_format(
		"#%.2X%.2X%.2X",
		math_ceil(self.R * 255),
		math_ceil(self.G * 255),
		math_ceil(self.B * 255)
	)
end

Color.TRANSPARENT = Color(  0,    0,    0,    0)
Color.BLACK       = Color(  0,    0,    0)
Color.WHITE       = Color(  1,    1,    1)

Color.RED         = Color(  1,    0,    0)
Color.GREEN       = Color(  0,    1,    0)
Color.BLUE        = Color(  0,    0,    1)

Color.YELLOW      = Color(  1,    1,    0)
Color.CYAN        = Color(  0,    1,    1)
Color.MAGENTA     = Color(  1,    0,    1)

Color.ORANGE      = Color(  1,  0.5,    0)
Color.CHARTREUSE  = Color(0.5,    1,    1)
Color.AQUAMARINE  = Color(  0,    1,  0.5)
Color.AZURE       = Color(  0,  0.5,    1)
Color.VIOLET      = Color(0.5,    0,    1)
Color.ROSE        = Color(  1,    0,  0.5)

Color.PALETTE = {
	Color.BLACK,
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA,
	Color.ORANGE,
	Color.CHARTREUSE,
	Color.AQUAMARINE,
	Color.AZURE,
	Color.VIOLET,
	Color.ROSE,
}

function Color.RandomPalette(includes_black)
	local skips = (includes_black == false) and 1 or 0
	return Color.PALETTE[math_random(#Color.PALETTE - skips) + skips]
end

function Color.Random()
	return Color(math_random(), math_random(), math_random())
end

function Color.FromRGBA(r, g, b, a)
	return Color(
		math_min(tonumber(r       ) or 0  , 255) / 255,
		math_min(tonumber(g       ) or 0  , 255) / 255,
		math_min(tonumber(b       ) or 0  , 255) / 255,
		math_min(tonumber(a or 255) or 255, 255) / 255
		-- default to Color.new^^^     ^^^-in case tonumber fails (invalid string)
	)
end

function Color.FromCYMK(c, y, m, k, a)
	a = a or 1

	local r = c * (1 - k) + k
	local g = m * (1 - k) + k
	local b = y * (1 - k) + k

	return Color(1 - r, 1 - g, 1 - b, a)
end

local function hue2rgb(p, q, t)
	if (t < 0) then t = t + 1 end
	if (t > 1) then t = t - 1 end
	if (t < 1 / 6) then return p + (q - p) * 6 * t end
	if (t < 1 / 2) then return q end
	if (t < 2 / 3) then return p + (q - p) * (2 / 3 - t) * 6 end
	return p
end

function Color.FromHSL(h, s, l)
	h = h / 360

	local r, g, b

	if (s == 0) then
		r, g, b = l, l, l -- achromatic
	else
		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1 / 3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1 / 3)
	end

	return Color(r, g, b)
end

function Color.FromHSV(h, s, v)
	local l = (2 - s) * v / 2

	if (l ~= 0) then
		if (l == 1) then
			s = 0
		elseif (l < .5) then
			s = s * v / (l * 2)
		else
			s = s * v / (2 - l * 2)
		end
	end

	return Color.FromHSL(h, s, l)
end

function Color.FromHex(hex)
	local maybeHashtag = string_sub(hex, 1, 1)
	if (maybeHashtag == "#") then
		hex = string_sub(hex, 2)
	end

	local number = tonumber(hex, 16)

	-- is a shorthanded version
	if (#hex == 3 or #hex == 4) then
		-- is alpha not defined
		if (#hex == 3) then
			number = (number << 4) + 15
		end

		return Color(
			(number >> 12 & 15) / 15,
			(number >> 8 & 15) / 15,
			(number >> 4 & 15) / 15,
			(number & 15) / 15
		)
	end

	-- is a full hex
	if (#hex == 6 or #hex == 8) then
		-- is alpha not defined
		if (#hex == 6) then
			number = (number << 8) + 255
		end

		return Color.FromRGBA(
			number >> 24 & 255,
			number >> 16 & 255,
			number >> 8 & 255,
			number & 255
		)
	end
end

Color.FromHEX = Color.FromHex -- backward compatibility
