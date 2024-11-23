--!native

--[[
	i literally just copy pasted the packetIDs code. :D
]]
local dict = {}

local queryIDs = {}

function queryIDs.set(id: number, query: any)
	dict[id] = query
end

function queryIDs.ref()
	return dict
end

return queryIDs
