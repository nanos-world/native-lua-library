-- Overrides print to call Console Log instead
print = function(...)
	--caching
	local buffer, _tostring, _concat = {...}, tostring, table.concat

    for i = 1, select("#", ...) do
        buffer[i] = _tostring(buffer[i])
    end

	-- After all, concatenate the results
    return Console.Log(_concat(buffer, '\t'))
end

-- Generates a random seed based on the current time for this session
math.randomseed(os.time())
