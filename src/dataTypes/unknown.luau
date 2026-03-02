local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local readRefs = require(script.Parent.Parent.process.readRefs)
local types = require(script.Parent.Parent.types)

local reference = bufferWriter.reference
local alloc = bufferWriter.alloc

return function(): types.dataTypeInterface<unknown>
	return {
		write = function(value: unknown)
			alloc(2)
			reference(value)
		end,

		read = function(b: buffer, cursor: number)
			local refs = readRefs.get()

			if not refs then
				return nil, 2
			end

			return refs[buffer.readu16(b, cursor)], 2
		end,
	}
end
