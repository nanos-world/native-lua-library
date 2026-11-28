-- Overrides print to call Console Log instead
print = function(...)
	Console.Log(string.format(string.rep("%s\t", select("#", ...)), ...))
end

-- Overrides warn to call Console Warn instead
-- Note: The lua warn function expects a valid first parameter and strings, this implementation accepts everything and the first parameter isn't needed.
warn = function(...)
	Console.Warn(string.format(string.rep("%s\t", select("#", ...)), ...))
end

-- Generates a random seed based on the current time for this session
math.randomseed(os.time())
