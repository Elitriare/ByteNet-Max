local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32NoAlloc = bufferWriter.f32NoAlloc
local alloc = bufferWriter.alloc

local cframe = {
	read = function(b: buffer, cursor: number)
		local x : number = buffer.readf32(b, cursor)
		local y : number = buffer.readf32(b, cursor + 4)
		local z : number = buffer.readf32(b, cursor + 8)
		local rx : number = buffer.readf32(b, cursor + 12)
		local ry : number = buffer.readf32(b, cursor + 16)
		local rz : number = buffer.readf32(b, cursor + 20)

		return CFrame.Angles(rx, ry, rz) + Vector3.new(x, y, z), 24
	end,
	write = function(value: CFrame)
		local x : number, y : number, z : number = value.X, value.Y, value.Z
		local axis : Vector3, angle : number = value:ToAxisAngle()
		axis *= angle

		local rx : number, ry : number, rz : number = axis.X, axis.Y, axis.Z

		-- Math done, write it now
		alloc(24)
		f32NoAlloc(x)
		f32NoAlloc(y)
		f32NoAlloc(z)
		f32NoAlloc(rx)
		f32NoAlloc(ry)
		f32NoAlloc(rz)
	end,
}

return function(): types.dataTypeInterface<CFrame>
	return cframe
end