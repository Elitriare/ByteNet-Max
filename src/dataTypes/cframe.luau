local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32NoAlloc = bufferWriter.f32NoAlloc
local alloc = bufferWriter.alloc

local cframe = {
	read = function(b: buffer, cursor: number)
		local x: number = buffer.readf32(b, cursor)
		local y: number = buffer.readf32(b, cursor + 4)
		local z: number = buffer.readf32(b, cursor + 8)
		local rx: number = buffer.readf32(b, cursor + 12)
		local ry: number = buffer.readf32(b, cursor + 16)
		local rz: number = buffer.readf32(b, cursor + 20)

		local axis: Vector3 = Vector3.new(rx, ry, rz)
		local angle: number = axis.Magnitude

		if angle ~= 0 then
			-- fromAxisAngle will normalize the axis so we don't need to do it here
			return CFrame.new(x, y, z) * CFrame.fromAxisAngle(axis, angle), 24
		else
			return CFrame.new(x, y, z), 24
		end
	end,
	write = function(value: CFrame)
		local x: number, y: number, z: number = value.X, value.Y, value.Z
		local axis: Vector3, angle: number = value:ToAxisAngle()
		axis *= angle
		local rx: number, ry: number, rz: number = axis.X, axis.Y, axis.Z

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
