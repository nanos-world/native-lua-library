-- Nanos Math Library
NanosMath = {}

function NanosMath.Round(value, decimals)
	local decimal_shift = (10 ^ (decimals or 0))
	return (math.floor((value * decimal_shift) + 0.5) / decimal_shift)
end

function NanosMath.Clamp(value, low, high)
	return math.min(math.max(value, low), high)
end

function NanosMath.ClampAxis(angle)
	local new_angle = angle % 360

	if (new_angle < 0) then
		new_angle = new_angle + 360
	end

	return new_angle
end

function NanosMath.NormalizeAxis(angle)
	local new_angle = NanosMath.ClampAxis(angle)

	if (new_angle > 180) then
		new_angle = new_angle - 360
	end

	return new_angle
end

function NanosMath.FInterpTo(current, target, delta_time, interp_speed)
	if (interp_speed <= 0) then return target end

	local delta = target - current

	if (math.sqrt(delta) < 0.00001) then return target end

	local delta_move = delta * NanosMath.Clamp(delta_time * interp_speed, 0, 1)

	return current + delta_move
end

function NanosMath.RInterpTo(current, target, delta_time, interp_speed)
	if (interp_speed <= 0) then return target end

	local delta = (target - current):GetNormalized()

	if (delta:IsNearlyZero()) then return target end

	local delta_move = delta * NanosMath.Clamp(delta_time * interp_speed, 0, 1)

	return (current + delta_move):GetNormalized()
end

function NanosMath.VInterpTo(current, target, delta_time, interp_speed)
	if (interp_speed <= 0) then return target end

	local delta = target - current

	if (delta:IsNearlyZero()) then return target end

	local delta_move = delta * NanosMath.Clamp(delta_time * interp_speed, 0, 1)

	return current + delta_move
end

function NanosMath.VInterpConstantTo(current, target, delta_time, interp_speed)
	local delta = target - current
	local delta_m = delta:Size()
	local max_step = interp_speed * delta_time

	if (delta_m > max_step) then
		if (max_step > 0) then
			local delta_n = delta / delta_m
			return current + delta_n * max_step
		end
	else
		return current
	end

	return target
end

function NanosMath.RInterpConstantTo(current, target, delta_time, interp_speed)
	if (delta_time == 0 or current == target) then return current end
	if (interp_speed <= 0) then return target end

	local delta_interp_speed = interp_speed * delta_time
	local delta_move = (target - current):GetNormalized()

	local result = Rotator(
		NanosMath.Clamp(delta_move.Pitch, -delta_interp_speed, delta_interp_speed),
		NanosMath.Clamp(delta_move.Yaw, -delta_interp_speed, delta_interp_speed),
		NanosMath.Clamp(delta_move.Roll, -delta_interp_speed, delta_interp_speed)
	)

	result:Normalize()

	return result
end

function NanosMath.RelativeTo(location, rotation, actor)
	local actor_location = actor:GetLocation()
	local actor_quaternion = actor:GetRotation():Quaternion()
	local relative_location = actor_quaternion:UnrotateVector(location - actor_location) / actor:GetScale()

	-- Gets the Relative rotation
	local inverse = actor_quaternion:Inverse()
	local relative_rotation = (inverse * rotation:Quaternion()):Rotator()

	return relative_location, relative_rotation
end

function NanosMath.LocalToWorld(local_location, local_rotation, actor)
	local actor_location = actor:GetLocation()
	local actor_rotation = actor:GetRotation()
	local actor_scale = actor:GetScale()

	local forward = actor_rotation:GetForwardVector() * actor_scale
	local right = actor_rotation:GetRightVector() * actor_scale
	local up = actor_rotation:GetUpVector() * actor_scale

	local world_location = actor_location + (forward * local_location.X) + (right * local_location.Y) + (up * local_location.Z)
	local world_rotation = actor_rotation + local_rotation

	return world_location, world_rotation
end

function NanosMath.RandomFloat(min, max)
	return min + math.random() * (max - min)
end
