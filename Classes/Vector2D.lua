-- 2D Vector

Vector2D = {}
Vector2D.__index = Vector2D

setmetatable(Vector2D, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local tonumber = tonumber
local type = type
local string_format = string.format

function Vector2D.new(x, y)
	x = tonumber(x) or 0
	return setmetatable({
		X = x,
		Y = tonumber(y) or x
	}, Vector2D)
end

function Vector2D:__add(other)
	-- Vector2D + number
	if (type(other) == "number") then
		return Vector2D(self.X + other, self.Y + other)
	end

	-- number + Vector2D
	if (type(self) == "number") then
		return Vector2D(self + other.X, self + other.Y)
	end

	-- Assume Vector2D + Vector2D
	return Vector2D(self.X + other.X, self.Y + other.Y)
end

function Vector2D:__sub(other)
	-- Vector2D - number
	if (type(other) == "number") then
		return Vector2D(self.X - other, self.Y - other)
	end

	-- Assume Vector2D - Vector2D
	return Vector2D(self.X - other.X, self.Y - other.Y)
end

function Vector2D:__mul(other)
	-- Vector2D * number
	if (type(other) == "number") then
		return Vector2D(self.X * other, self.Y * other)
	end

	-- number * Vector2D
	if (type(self) == "number") then
		return Vector2D(self * other.X, self * other.Y)
	end

	-- Assume Vector2D * Vector2D
	return Vector2D(self.X * other.X, self.Y * other.Y)
end

function Vector2D:__div(other)
	-- Vector2D / number
	if (type(other) == "number") then
		return Vector2D(self.X / other, self.Y / other)
	end

	-- Assume Vector2D / Vector2D
	return Vector2D(self.X / other.X, self.Y / other.Y)
end

function Vector2D:__unm()
	return Vector2D(-self.X, -self.Y)
end

function Vector2D:__eq(other)
	return self.X == other.X and self.Y == other.Y
end

function Vector2D:__tostring()
	return string_format("Vector2D(X = %.2f, Y = %.2f)", self.X, self.Y)
end
