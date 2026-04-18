-- Matrix

Matrix = {}
Matrix.__index = Matrix

setmetatable(Matrix, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

function Matrix.new(rotation, origin)
	local _self = setmetatable({}, Matrix)
	_self.M = {}

	for i = 1, 4 do
		_self.M[i] = {}
		for j = 1, 4 do
			_self.M[i][j] = 0
		end
	end

	if (getmetatable(rotation) == Rotator) then
		local pitch_rad = rotation.Pitch * (math.pi / 180)
		local yaw_rad = rotation.Yaw * (math.pi / 180)
		local roll_rad = rotation.Roll * (math.pi / 180)

		local cp = math.cos(pitch_rad)
		local sp = math.sin(pitch_rad)

		local cy = math.cos(yaw_rad)
		local sy = math.sin(yaw_rad)

		local cr = math.cos(roll_rad)
		local sr = math.sin(roll_rad)

		_self.M[1][1] = cp * cy
		_self.M[1][2] = cp * sy
		_self.M[1][3] = sp
		_self.M[1][4] = 0

		_self.M[2][1] = sr * sp * cy - cr * sy
		_self.M[2][2] = sr * sp * sy + cr * cy
		_self.M[2][3] = -sr * cp
		_self.M[2][4] = 0

		_self.M[3][1] = -(cr * sp * cy + sr * sy)
		_self.M[3][2] = cy * sr - cr * sp * sy
		_self.M[3][3] = cr * cp
		_self.M[3][4] = 0

		if (getmetatable(origin) == Vector) then
			_self.M[4][1] = origin.X
			_self.M[4][2] = origin.Y
			_self.M[4][3] = origin.Z
		else
			_self.M[4][1] = 0
			_self.M[4][2] = 0
			_self.M[4][3] = 0
		end
		_self.M[4][4] = 1
	end

	return _self
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

	m.M[1][1] = self.M[1][1];
	m.M[1][2] = self.M[2][1];
	m.M[1][3] = self.M[3][1];
	m.M[1][4] = self.M[4][1];

	m.M[2][1] = self.M[1][2];
	m.M[2][2] = self.M[2][2];
	m.M[2][3] = self.M[3][2];
	m.M[2][4] = self.M[4][2];

	m.M[3][1] = self.M[1][3];
	m.M[3][2] = self.M[2][3];
	m.M[3][3] = self.M[3][3];
	m.M[3][4] = self.M[4][3];

	m.M[4][1] = self.M[1][4];
	m.M[4][2] = self.M[2][4];
	m.M[4][3] = self.M[3][4];
	m.M[4][4] = self.M[4][4];

	return m;
end

function Matrix:__tostring()
	return "Matrix(" .. self.M[1][1] .. ",	" .. self.M[1][2] .. ",	" .. self.M[1][3] .. ",	" .. self.M[1][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[2][1] .. ",	" .. self.M[2][2] .. ",	" .. self.M[2][3] .. ",	" .. self.M[2][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[3][1] .. ",	" .. self.M[3][2] .. ",	" .. self.M[3][3] .. ",	" .. self.M[3][4] .. "\n" ..
		"\t\t\t\t\t" .. self.M[4][1] .. ",	" .. self.M[4][2] .. ",	" .. self.M[4][3] .. ",	" .. self.M[4][4] .. ")"
end