-- Quaternion

Quat = {}
Quat.__index = Quat

setmetatable(Quat, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local tonumber = tonumber
local type = type
local string_format = string.format

-- Localized frequently used math functions for performance
local math_sqrt = math.sqrt
local math_atan = math.atan
local math_asin = math.asin

-- Constants
local RAD_TO_DEG = 180 / math.pi
local SINGULARITY_THRESHOLD = 0.4999995

function Quat.new(x, y, z, w)
	x = tonumber(x) or 0
	return setmetatable({
		X = x,
		Y = tonumber(y) or x,
		Z = tonumber(z) or x,
		W = tonumber(w) or x
	}, Quat)
end

function Quat:__mul(other)
	-- Quat * number
	if (type(other) == "number") then
		return Quat(self.X * other, self.Y * other, self.Z * other, self.W * other)
	end

	-- number * Quat
	if (type(self) == "number") then
		return Quat(self * other.X, self * other.Y, self * other.Z, self * other.W)
	end

	-- Assume Quat * Quat
	local T0 = (self.Z - self.Y) * (other.Y - other.Z)
	local T1 = (self.W + self.X) * (other.W + other.X)
	local T2 = (self.W - self.X) * (other.Y + other.Z)
	local T3 = (self.Y + self.Z) * (other.W - other.X)
	local T4 = (self.Z - self.X) * (other.X - other.Y)
	local T5 = (self.Z + self.X) * (other.X + other.Y)
	local T6 = (self.W + self.Y) * (other.W - other.Z)
	local T7 = (self.W - self.Y) * (other.W + other.Z)
	local T8 = T5 + T6 + T7
	local T9 = 0.5 * (T4 + T8)

	return Quat(
		T1 + T9 - T8,
		T2 + T9 - T7,
		T3 + T9 - T6,
		T0 + T9 - T5
	)
end

function Quat:__sub(other)
	return Quat(
		self.X - other.X,
		self.Y - other.Y,
		self.Z - other.Z,
		self.W - other.W
	)
end

function Quat:__add(other)
	return Quat(
		self.X + other.X,
		self.Y + other.Y,
		self.Z + other.Z,
		self.W + other.W
	)
end

function Quat:Normalize(tolerance)
	if not tolerance then tolerance = 0.000001 end

	local square_sum = self.X * self.X + self.Y * self.Y + self.Z * self.Z + self.W * self.W

	if (square_sum >= tolerance) then
		local scale = 1 / math_sqrt(square_sum)

		self.X = self.X * scale
		self.Y = self.Y * scale
		self.Z = self.Z * scale
		self.W = self.W * scale
	else
		self.X = 0
		self.Y = 0
		self.Z = 0
		self.W = 1
	end
end

function Quat:Inverse()
	return Quat(-self.X, -self.Y, -self.Z, self.W)
end

function Quat:RotateVector(vector)
	local QX, QY, QZ, QW = self.X, self.Y, self.Z, self.W
	local VX, VY, VZ = vector.X, vector.Y, vector.Z

	local T1 = 2 * (QY * VZ - QZ * VY)
	local T2 = 2 * (QZ * VX - QX * VZ)
	local T3 = 2 * (QX * VY - QY * VX)

	local RX = VX + QW * T1 + (QY * T3 - QZ * T2)
	local RY = VY + QW * T2 + (QZ * T1 - QX * T3)
	local RZ = VZ + QW * T3 + (QX * T2 - QY * T1)

	return Vector(RX, RY, RZ)

	-- Equivalent to
	-- local q = Vector(self.X, self.Y, self.Z)
	-- local tt = 2.0 * q:Cross(vector)
	-- local result = vector + (self.W * tt) + q:Cross(tt)
	-- return result
end

function Quat:UnrotateVector(vector)
	local QX, QY, QZ, QW = -self.X, -self.Y, -self.Z, self.W
	local VX, VY, VZ = vector.X, vector.Y, vector.Z

	local T1 = 2 * (QY * VZ - QZ * VY)
	local T2 = 2 * (QZ * VX - QX * VZ)
	local T3 = 2 * (QX * VY - QY * VX)

	local RX = VX + QW * T1 + (QY * T3 - QZ * T2)
	local RY = VY + QW * T2 + (QZ * T1 - QX * T3)
	local RZ = VZ + QW * T3 + (QX * T2 - QY * T1)

	return Vector(RX, RY, RZ)

	-- Equivalent to
	-- local q = Vector(-self.X, -self.Y, -self.Z)
	-- local tt = 2.0 * q:Cross(vector)
	-- local result = vector + (self.W * tt) + q:Cross(tt)
	-- return result
end

function Quat:GetForwardVector()
	return self:RotateVector({ X = 1, Y = 0, Z = 0 })
end

function Quat:GetRightVector()
	return self:RotateVector({ X = 0, Y = 1, Z = 0 })
end

function Quat:GetUpVector()
	return self:RotateVector({ X = 0, Y = 0, Z = 1 })
end

function Quat:Rotator()
	local singularity_test = self.Z * self.X - self.W * self.Y
	local yaw_y = 2 * (self.W * self.Z + self.X * self.Y)
	local yaw_x = 1 - 2 * (self.Y * self.Y + self.Z * self.Z)

	local rotator = Rotator()

	if (singularity_test < -SINGULARITY_THRESHOLD) then
		rotator.Pitch = -90
		rotator.Yaw = math_atan(yaw_y, yaw_x) * RAD_TO_DEG
		rotator.Roll = NanosMath.NormalizeAxis(-rotator.Yaw - (2 * math_atan(self.X, self.W) * RAD_TO_DEG))
	elseif (singularity_test > SINGULARITY_THRESHOLD) then
		rotator.Pitch = 90
		rotator.Yaw = math_atan(yaw_y, yaw_x) * RAD_TO_DEG
		rotator.Roll = NanosMath.NormalizeAxis(rotator.Yaw - (2 * math_atan(self.X, self.W) * RAD_TO_DEG))
	else
		rotator.Pitch = math_asin(2 * singularity_test) * RAD_TO_DEG
		rotator.Yaw = math_atan(yaw_y, yaw_x) * RAD_TO_DEG
		rotator.Roll = math_atan(-2 * (self.W * self.X + self.Y * self.Z), (1 - 2 * (self.X * self.X + self.Y * self.Y))) *
		RAD_TO_DEG
	end

	return rotator
end

function Quat:__tostring()
	return string_format("Quat(X = %.4f, Y = %.4f, Z = %.4f, W = %.4f)", self.X, self.Y, self.Z, self.W)
end
