local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local lz4 = require("../lz4")

local u16 = bufferWriter.u16
local writestring = bufferWriter.writestring
local dyn_alloc = bufferWriter.dyn_alloc

local str = {
	-- 2 bytes for the length, then the string

	read = function(b: buffer, cursor: number)
		local length = buffer.readu16(b, cursor)

		return lz4.decompressString(buffer.readstring(b, cursor + 2, length)), length + 2
	end,
	write = function(original: string)
		local data = lz4.compressString(original)
		local length = string.len(data)
		u16(length)

		dyn_alloc(length)
		writestring(data)
	end,
}

return function(): types.dataTypeInterface<string>
	return str
end
