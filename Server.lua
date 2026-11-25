-- Adds 'Package.Require' to searchers
table.insert(package.searchers, function(module_name)
	local success, result = pcall(Package.Require, module_name)
	if (success) then
		return function() return result end
	end
end)
