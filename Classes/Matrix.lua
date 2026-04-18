-- Matrix

Matrix = {}
Matrix.__index = Matrix

setmetatable(Matrix, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

-- Localized frequently used math functions for performance
local math_cos = math.cos
local math_sin = math.sin

-- Degrees to radians conversion constant
local DEG_TO_RAD = math.pi / 180

function Matrix.new(rotation, origin)
	local self = {
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 }
	}

	if (getmetatable(rotation) == Rotator) then
		local pitch_rad = rotation.Pitch * DEG_TO_RAD
		local yaw_rad = rotation.Yaw * DEG_TO_RAD
		local roll_rad = rotation.Roll * DEG_TO_RAD

		local cp = math_cos(pitch_rad)
		local sp = math_sin(pitch_rad)

		local cy = math_cos(yaw_rad)
		local sy = math_sin(yaw_rad)

		local cr = math_cos(roll_rad)
		local sr = math_sin(roll_rad)

		self[1][1] = cp * cy
		self[1][2] = cp * sy
		self[1][3] = sp
		self[1][4] = 0

		self[2][1] = sr * sp * cy - cr * sy
		self[2][2] = sr * sp * sy + cr * cy
		self[2][3] = -sr * cp
		self[2][4] = 0

		self[3][1] = -(cr * sp * cy + sr * sy)
		self[3][2] = cy * sr - cr * sp * sy
		self[3][3] = cr * cp
		self[3][4] = 0

		if (getmetatable(origin) == Vector) then
			self[4][1] = origin.X
			self[4][2] = origin.Y
			self[4][3] = origin.Z
		else
			self[4][1] = 0
			self[4][2] = 0
			self[4][3] = 0
		end
		self[4][4] = 1
	end

	return setmetatable({
		M = self
	}, Matrix)
end

function Matrix:TransformVector(vector)
	return Vector(
		self.M[1][1] * vector.X + self.M[2][1] * vector.Y + self.M[3][1] * vector.Z,
		self.M[1][2] * vector.X + self.M[2][2] * vector.Y + self.M[3][2] * vector.Z,
		self.M[1][3] * vector.X + self.M[2][3] * vector.Y + self.M[3][3] * vector.Z
	)
end

function Matrix:GetTransposed()
	local m = Matrix()

	m.M[1][1] = self.M[1][1]
	m.M[1][2] = self.M[2][1]
	m.M[1][3] = self.M[3][1]
	m.M[1][4] = self.M[4][1]

	m.M[2][1] = self.M[1][2]
	m.M[2][2] = self.M[2][2]
	m.M[2][3] = self.M[3][2]
	m.M[2][4] = self.M[4][2]

	m.M[3][1] = self.M[1][3]
	m.M[3][2] = self.M[2][3]
	m.M[3][3] = self.M[3][3]
	m.M[3][4] = self.M[4][3]

	m.M[4][1] = self.M[1][4]
	m.M[4][2] = self.M[2][4]
	m.M[4][3] = self.M[3][4]
	m.M[4][4] = self.M[4][4]

	return m
end

function Matrix:__tostring()
	return "Matrix(" .. self.M[1][1] .. ",	" .. self.M[1][2] .. ",	" .. self.M[1][3] .. ",	" .. self.M[1][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[2][1] .. ",	" .. self.M[2][2] .. ",	" .. self.M[2][3] .. ",	" .. self.M[2][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[3][1] .. ",	" .. self.M[3][2] .. ",	" .. self.M[3][3] .. ",	" .. self.M[3][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[4][1] .. ",	" .. self.M[4][2] .. ",	" .. self.M[4][3] .. ",	" .. self.M[4][4] .. ")"
end
