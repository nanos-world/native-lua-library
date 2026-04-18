-- Rotator

Rotator = {}
Rotator.__index = Rotator

setmetatable(Rotator, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local tonumber = tonumber

-- Localized frequently used math functions for performance
local math_abs = math.abs
local math_cos = math.cos
local math_rad = math.rad
local math_random = math.random
local math_sin = math.sin

-- Constants
local DEG_TO_RAD = math.pi / 180
local DEG_TO_HALF_RAD = DEG_TO_RAD * 0.5

function Rotator.new(_pitch, _yaw, _roll)
	local Pitch = tonumber(_pitch) or 0
	return setmetatable({
		Pitch = Pitch,
		Yaw = tonumber(_yaw) or Pitch,
		Roll = tonumber(_roll) or Pitch
	}, Rotator)
end

function Rotator:__add(other)
	-- Rotator + number
	if (type(other) == "number") then
		return Rotator(self.Pitch + other, self.Yaw + other, self.Roll + other)
	end

	-- number + Rotator
	if (type(self) == "number") then
		return Rotator(self + other.Pitch, self + other.Yaw, self + other.Roll)
	end

	-- Assume Rotator + Rotator
	return Rotator(self.Pitch + other.Pitch, self.Yaw + other.Yaw, self.Roll + other.Roll)
end

function Rotator:__sub(other)
	-- Rotator - number
	if (type(other) == "number") then
		return Rotator(self.Pitch - other, self.Yaw - other, self.Roll - other)
	end

	-- Assume Rotator - Rotator
	return Rotator(self.Pitch - other.Pitch, self.Yaw - other.Yaw, self.Roll - other.Roll)
end

function Rotator:__mul(other)
	-- Rotator * number
	if (type(other) == "number") then
		return Rotator(self.Pitch * other, self.Yaw * other, self.Roll * other)
	end

	-- number * Rotator
	if (type(self) == "number") then
		return Rotator(self * other.Pitch, self * other.Yaw, self * other.Roll)
	end

	-- Assume Rotator * Rotator
	return Rotator(self.Pitch * other.Pitch, self.Yaw * other.Yaw, self.Roll * other.Roll)
end

function Rotator:__tostring()
	return string.format("Rotator(Pitch = %.2f, Yaw = %.2f, Roll = %.2f)", self.Pitch, self.Yaw, self.Roll)
end

function Rotator:Equals(other, tolerance)
	if not tolerance then tolerance = 0.000001 end

	return
		math_abs(NanosMath.NormalizeAxis(self.Pitch - other.Pitch)) <= tolerance and
		math_abs(NanosMath.NormalizeAxis(self.Yaw - other.Yaw)) <= tolerance and
		math_abs(NanosMath.NormalizeAxis(self.Roll - other.Roll)) <= tolerance
end

function Rotator:GetNormalized()
	local new_rotation = Rotator(self.Pitch, self.Yaw, self.Roll)
	new_rotation:Normalize()
	return new_rotation
end

function Rotator:IsNearlyZero(tolerance)
	if not tolerance then tolerance = 0.000001 end

	return
		math_abs(self.Pitch) <= tolerance and
		math_abs(self.Yaw) <= tolerance and
		math_abs(self.Roll) <= tolerance
end

function Rotator:IsZero()
	return self.Pitch == 0 and self.Yaw == 0 and self.Roll == 0
end

function Rotator:RotateVector(vector)
	return Matrix(self):TransformVector(vector)
end

function Rotator:UnrotateVector(vector)
	return Matrix(self):GetTransposed():TransformVector(vector)
end

function Rotator:GetForwardVector()
	local pitch_no_winding = self.Pitch % 360
	local yaw_no_winding = self.Yaw % 360

	local RP = math_rad(pitch_no_winding)
	local RY = math_rad(yaw_no_winding)

	local SP = math_sin(RP)
	local CP = math_cos(RP)

	local SY = math_sin(RY)
	local CY = math_cos(RY)

	return Vector(CP * CY, CP * SY, SP)
end

function Rotator:GetRightVector()
	local m = Matrix(self)
	return Vector(m.M[2][1], m.M[2][2], m.M[2][3])
end

function Rotator:GetUpVector()
	local m = Matrix(self)
	return Vector(m.M[3][1], m.M[3][2], m.M[3][3])
end

function Rotator:Normalize()
	self.Pitch = NanosMath.NormalizeAxis(self.Pitch)
	self.Yaw = NanosMath.NormalizeAxis(self.Yaw)
	self.Roll = NanosMath.NormalizeAxis(self.Roll)
end

function Rotator:Quaternion()
	local pitch_no_winding = self.Pitch % 360
	local yaw_no_winding = self.Yaw % 360
	local roll_no_winding = self.Roll % 360

	local pitch_mult_rads = pitch_no_winding * DEG_TO_HALF_RAD
	local yaw_mult_rads = yaw_no_winding * DEG_TO_HALF_RAD
	local roll_mult_rads = roll_no_winding * DEG_TO_HALF_RAD

	local SP = math_sin(pitch_mult_rads)
	local CP = math_cos(pitch_mult_rads)
	local SY = math_sin(yaw_mult_rads)
	local CY = math_cos(yaw_mult_rads)
	local SR = math_sin(roll_mult_rads)
	local CR = math_cos(roll_mult_rads)

	return Quat(
		CR * SP * SY - SR * CP * CY,
		-CR * SP * CY - SR * CP * SY,
		CR * CP * SY - SR * SP * CY,
		CR * CP * CY + SR * SP * SY
	)
end

function Rotator.Random(roll, min, max)
	min = (type(min) == "number") and min or -180
	max = (type(max) == "number") and max or 180

	return Rotator(
		min + math_random() * (max - min),
		min + math_random() * (max - min),
		roll and min + math_random() * (max - min) or 0
	)
end
