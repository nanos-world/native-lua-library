Rotator = {}
Rotator.__index = Rotator

setmetatable(Rotator, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

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
		math.abs(NanosMath.NormalizeAxis(self.Pitch - other.Pitch)) <= tolerance and
		math.abs(NanosMath.NormalizeAxis(self.Yaw - other.Yaw)) <= tolerance and
		math.abs(NanosMath.NormalizeAxis(self.Roll - other.Roll)) <= tolerance
end

function Rotator:GetNormalized()
	local new_rotation = Rotator(self.Pitch, self.Yaw, self.Roll)
	new_rotation:Normalize()
	return new_rotation
end

function Rotator:IsNearlyZero(tolerance)
	if not tolerance then tolerance = 0.000001 end

	return
		math.abs(self.Pitch) <= tolerance and
		math.abs(self.Yaw) <= tolerance and
		math.abs(self.Roll) <= tolerance
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

	local RP = math.rad(pitch_no_winding)
	local RY = math.rad(yaw_no_winding)

	local SP = math.sin(RP)
	local CP = math.cos(RP)

	local SY = math.sin(RY)
	local CY = math.cos(RY)

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
	local deg_to_rad = math.pi / 180
	local rads_divided_by_2 = deg_to_rad / 2

	local pitch_no_winding = self.Pitch % 360
	local yaw_no_winding = self.Yaw % 360
	local roll_no_winding = self.Roll % 360

	local pitch_mult_rads = pitch_no_winding * rads_divided_by_2
	local yaw_mult_rads = yaw_no_winding * rads_divided_by_2
	local roll_mult_rads = roll_no_winding * rads_divided_by_2

	local SP = math.sin(pitch_mult_rads)
	local CP = math.cos(pitch_mult_rads)
	local SY = math.sin(yaw_mult_rads)
	local CY = math.cos(yaw_mult_rads)
	local SR = math.sin(roll_mult_rads)
	local CR = math.cos(roll_mult_rads)

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
		min + math.random() * (max - min),
		min + math.random() * (max - min),
		roll and min + math.random() * (max - min) or 0
	)
end
