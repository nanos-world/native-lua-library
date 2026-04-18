--[[ Nanos Utils Library --]]

NanosUtils = {}


function NanosUtils.IsEntityValid(entity)
	if (not entity) then return false end

	local val_type = type(entity)
	if ((val_type == "userdata") or ((val_type == "table") and (type(entity.__entity) == "userdata"))) then
		return (entity.IsValid and entity:IsValid())
	end

	return false
end

function NanosUtils.Benchmark(name, amount, func, ...)
	-- Attempt to force GC (double call is intentional)
	collectgarbage()
	collectgarbage()

	-- Store current time
	local start_time = os.clock()

	-- Do the operation 'amount' times
	for _ = 1, amount do
		func(...)
	end

	-- Calculates the elapsed time in ms
	local elapsed_ms = (os.clock() - start_time) * 1000

	Console.Log("Benchmark '%s' (x%d) took %.0fms.", name, amount, elapsed_ms)

	return elapsed_ms
end
