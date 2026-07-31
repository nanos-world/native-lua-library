--[[ Vector2D --]]

Vector2D = {}
Vector2D.__index = Vector2D

setmetatable(Vector2D, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

function Vector2D.new(_X, _Y)
	local X = tonumber(_X) or 0
	return setmetatable({
		X = X,
		Y = tonumber(_Y) or X
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
	return string.format("Vector2D(X = %.2f, Y = %.2f)", self.X, self.Y)
end

function Vector2D:SizeSquared()
	return self.X * self.X + self.Y * self.Y
end

function Vector2D:Size()
	return math.sqrt(self:SizeSquared())
end

function Vector2D:IsNear(other, radius)
	return self:DistanceSquared(other) < radius * radius
end

function Vector2D:DistanceSquared(other)
	local X = other.X - self.X
	local Y = other.Y - self.Y

	return X * X + Y * Y
end

function Vector2D:Distance(other)
	return math.sqrt(self:DistanceSquared(other))
end

function Vector2D:Dot(other)
	return self.X * other.X + self.Y * other.Y
end

function Vector2D:Cross(other)
	return self.X * other.Y - self.Y * other.X
end

function Vector2D:Lerp(other, alpha)
	return self + (other - self) * alpha
end