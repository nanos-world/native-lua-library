-- Overrides print to call Console Log instead
print = function(...)
	return Console.Log(string.format(string.rep("%s\t", select("#", ...)), ...))
end

-- Generates a random seed based on the current time for this session
math.randomseed(os.time())
