-- Nanos Table Library
NanosTable = {}

function NanosTable.ShallowCopy(original_table)
	return __copy_table_shallow(original_table)
end

function NanosTable.Dump(original_table)
	-- Table used to store already visited tables (avoid recursion)
	local visited = {}

	-- Table used to store the final output, which will be concatenated in the end
	local buffer = {}

	-- Cache table.insert as local because it's faster
	local table_insert = table.insert

	-- Internal recursive function
	local function DumpRecursive(object, indentation)
		local object_type = type(object)

		-- If it's a table and was not outputted yet
		if (object_type == 'table' and type(object.__entity) ~= "userdata" and not visited[object]) then
			local object_metatable = getmetatable(object)

			-- If it's a framework struct, just stringify it
			if (object_metatable == Vector or object_metatable == Rotator or object_metatable == Vector2D or object_metatable == Color) then
				-- Anything else just stringify it
				table_insert(buffer, tostring(object))
				return
			end

			-- Marks as visited
			visited[object] = true

			-- Stores all keys in another table, sorting it
			local keys = {}

			for key in pairs(object) do
				table_insert(keys, key)
			end

			table.sort(keys, function(a, b)
				if (type(a) == "number" and type(b) == "number") then
					return a < b
				else
					return tostring(a) < tostring(b)
				end
			end)

			-- Increases one indentation, as we will start outputting table elements
			indentation = indentation + 1

			-- Main table displays '{' in a separated line, subsequent ones will be in the same line
			table_insert(buffer, indentation == 1 and "\n{" or "{")

			-- For each member of the table, recursively outputs it
			for k, key in ipairs(keys) do
				local formatted_key = type(key) == "number" and tostring(key) or '"' .. tostring(key) .. '"'

				-- Appends the Key with indentation
				table_insert(buffer, "\n" .. string.rep(" ", indentation * 4) .. formatted_key .. " = ")

				-- Appends the Element
				DumpRecursive(object[key], indentation)

				-- Appends a last comma
				table_insert(buffer, ",")
			end

			-- After outputted the whole table, backs one indentation
			indentation = indentation - 1

			-- Adds the closing bracket
			table_insert(buffer, "\n" .. string.rep(" ", indentation * 4) .. "}")
		elseif (object_type == "string") then
			-- Outputs string with quotes
			table_insert(buffer, '"' .. tostring(object) .. '"')
		else
			-- Anything else just stringify it
			table_insert(buffer, tostring(object))
		end
	end

	-- Main call
	DumpRecursive(original_table, 0)

	-- After all, concatenates the results
	return table.concat(buffer)
end
