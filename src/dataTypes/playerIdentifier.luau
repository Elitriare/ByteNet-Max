local types = require(script.Parent.Parent.types)
local bufferWriter = require(script.Parent.Parent.process.bufferWriter)

local pI = bufferWriter.playerIdentifier

local uint8 = {
	write = pI,

	read = function(b: buffer, cursor: number)
		local uint8, buf = buffer.readu8(b, cursor), 1
		assert(script.Parent.Parent.playerIdentifier:FindFirstChild(tostring(uint8)), "Invalid player")
		
		return script.Parent.Parent.playerIdentifier:FindFirstChild(tostring(uint8)).Value, buf
	end,
}

return function(): types.dataTypeInterface<number>
	return uint8
end
