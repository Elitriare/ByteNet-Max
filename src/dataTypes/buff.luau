local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u32 = bufferWriter.u32
local copy = bufferWriter.copy
local dyn_alloc = bufferWriter.dyn_alloc

local buff = {
	read = function(b: buffer, cursor: number)
		local length = buffer.readu32(b, cursor)
		local freshBuffer = buffer.create(length)

		-- copy the data from the main buffer to the new buffer with an offset of 4 because of length
		buffer.copy(freshBuffer, 0, b, cursor + 4, length)

		return freshBuffer, length + 4
	end,
	write = function(data: buffer)
		local length = buffer.len(data)
		u32(length)

		dyn_alloc(length)

		-- write the length of the buffer, then the buffer itself
		copy(data)
	end,
}

return function(): types.dataTypeInterface<buffer>
	return buff
end
