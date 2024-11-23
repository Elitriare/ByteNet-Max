--!native
--!optimize 2

local types = require(script.Parent.Parent.types)
local query = require(script.Parent.query)

return function(properties: types.queryProperties<any>)
	return function(id: number)
		return query(properties, id)
	end
end