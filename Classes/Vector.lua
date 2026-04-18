-- Vector

Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local tonumber = tonumber

-- Localized frequently used math functions for performance
local math_abs = math.abs
local math_atan = math.atan
local math_cos = math.cos
local math_sin = math.sin
local math_sqrt = math.sqrt

-- Radians to degrees conversion constant
local RAD_TO_DEG = 180.0 / math.pi

function Vector.new(_X, _Y, _Z)
	local X = tonumber(_X) or 0
	return setmetatable({
		X = X,
		Y = tonumber(_Y) or X,
		Z = tonumber(_Z) or X,
	}, Vector)
end

function Vector:__add(other)
	-- Vector + number
	if (type(other) == "number") then
		return Vector(self.X + other, self.Y + other, self.Z + other)
	end

	-- number + Vector
	if (type(self) == "number") then
		return Vector(self + other.X, self + other.Y, self + other.Z)
	end

	-- Assume Vector + Vector
	return Vector(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
end

function Vector:__sub(other)
	-- Vector - number
	if (type(other) == "number") then
		return Vector(self.X - other, self.Y - other, self.Z - other)
	end

	-- Assume Vector - Vector
	return Vector(self.X - other.X, self.Y - other.Y, self.Z - other.Z)
end

function Vector:__mul(other)
	-- Vector * number
	if (type(other) == "number") then
		return Vector(self.X * other, self.Y * other, self.Z * other)
	end

	-- number * Vector
	if (type(self) == "number") then
		return Vector(self * other.X, self * other.Y, self * other.Z)
	end

	-- Assume Vector * Vector
	return Vector(self.X * other.X, self.Y * other.Y, self.Z * other.Z)
end

function Vector:__div(other)
	-- Vector / number
	if (type(other) == "number") then
		return Vector(self.X / other, self.Y / other, self.Z / other)
	end

	-- Assume Vector / Vector
	return Vector(self.X / other.X, self.Y / other.Y, self.Z / other.Z)
end

function Vector:__pow(other)
	return Vector(
		self.Y * other.Z - self.Z * other.Y,
		self.Z * other.X - self.X * other.Z,
		self.X * other.Y - self.Y * other.X
	)
end

function Vector:__unm()
	return Vector(-self.X, -self.Y, -self.Z)
end

function Vector:__eq(other)
	return self.X == other.X and self.Y == other.Y and self.Z == other.Z
end

function Vector:__tostring()
	return string.format("Vector(X = %.2f, Y = %.2f, Z = %.2f)", self.X, self.Y, self.Z)
end

function Vector:Equals(other, tolerance)
	if (not tolerance) then tolerance = 0.000001 end

	return
		math_abs(self.X - other.X) <= tolerance and
		math_abs(self.Y - other.Y) <= tolerance and
		math_abs(self.Z - other.Z) <= tolerance
end

function Vector:SizeSquared()
	return self.X * self.X + self.Y * self.Y + self.Z * self.Z
end

function Vector:Size()
	return math_sqrt(self:SizeSquared())
end

function Vector:IsNearlyZero(tolerance)
	if (not tolerance) then tolerance = 0.000001 end

	return
		math_abs(self.X) <= tolerance and
		math_abs(self.Y) <= tolerance and
		math_abs(self.Z) <= tolerance
end

function Vector:IsZero()
	return self.X == 0 and self.Y == 0 and self.Z == 0
end

function Vector:IsNear(other, radius)
	return self:DistanceSquared(other) < radius * radius
end

function Vector:DistanceSquared(other)
	return ((other.X - self.X) ^ 2) + ((other.Y - self.Y) ^ 2) + ((other.Z - self.Z) ^ 2)
end

function Vector:Distance(other)
	return math_sqrt(self:DistanceSquared(other))
end

function Vector:Normalize(tolerance)
	if (not tolerance) then tolerance = 0.000001 end

	local square_sum = self:SizeSquared()

	if (square_sum > tolerance) then
		local scale = 1 / math_sqrt(square_sum)

		self.X = self.X * scale
		self.Y = self.Y * scale
		self.Z = self.Z * scale

		return true
	end

	return false
end

function Vector:GetUnsafeNormal()
	local scale = 1 / math_sqrt(self:SizeSquared())
	return self * scale
end

function Vector:GetSafeNormal(tolerance)
	if (not tolerance) then tolerance = 0.000001 end

	local square_sum = self:SizeSquared()

	if (square_sum == 1) then
		return Vector(self.X, self.Y, self.Z)
	elseif (square_sum < tolerance) then
		return Vector()
	end

	local scale = 1 / math_sqrt(square_sum)
	return self * scale
end

function Vector:ToOrientationRotator()
	return Rotator(
		math_atan(self.Z, math_sqrt(self.X * self.X + self.Y * self.Y)) * RAD_TO_DEG,
		math_atan(self.Y, self.X) * RAD_TO_DEG,
		0
	)
end

function Vector:ToOrientationQuat()
	local yaw_rad = math_atan(self.Y, self.X)
	local pitch_rad = math_atan(self.Z, math_sqrt(self.X * self.X + self.Y * self.Y))

	local SP = math_sin(pitch_rad * 0.5)
	local CP = math_cos(pitch_rad * 0.5)
	local SY = math_sin(yaw_rad * 0.5)
	local CY = math_cos(yaw_rad * 0.5)

	return Quat(
		SP * SY,
		-SP * CY,
		CP * SY,
		CP * CY
	)
end

function Vector:Dot(other)
	return self.X * other.X + self.Y * other.Y + self.Z * other.Z
end

function Vector:Cross(other)
	return Vector(
		self.Y * other.Z - self.Z * other.Y,
		self.Z * other.X - self.X * other.Z,
		self.X * other.Y - self.Y * other.X
	)
end
