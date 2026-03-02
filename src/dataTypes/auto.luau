local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local bool = require(script.Parent.bool)()
local uint8 = require(script.Parent.uint8)()
local uint16 = require(script.Parent.uint16)()
local uint32 = require(script.Parent.uint32)()
local int8 = require(script.Parent.int8)()
local int16 = require(script.Parent.int16)()
local int32 = require(script.Parent.int32)()
local float32 = require(script.Parent.float32)()
local float64 = require(script.Parent.float64)()
local stringType = require(script.Parent.string)()
local vec2 = require(script.Parent.vec2)()
local vec3 = require(script.Parent.vec3)()
local color3 = require(script.Parent.color3)()
local cframe = require(script.Parent.cframe)()
local unknown = require(script.Parent.unknown)()

local writeU8 = bufferWriter.u8

type codec = {
	id: number,
	read: (b: buffer, cursor: number) -> (unknown, number),
	write: (value: unknown) -> (),
	matches: (value: unknown) -> boolean,
}

local function numberFitsFloat32(value: number): boolean
	if value ~= value then
		return true
	end

	local test = buffer.create(4)
	buffer.writef32(test, 0, value)

	return buffer.readf32(test, 0) == value
end

local function numberCodecFor(value: number): types.dataTypeInterface<number>
	if value % 1 == 0 then
		if value >= 0 then
			if value <= 255 then
				return uint8
			elseif value <= 65535 then
				return uint16
			elseif value <= 4294967295 then
				return uint32
			end
		end

		if value >= -128 and value <= 127 then
			return int8
		elseif value >= -32768 and value <= 32767 then
			return int16
		elseif value >= -2147483648 and value <= 2147483647 then
			return int32
		end
	end

	if numberFitsFloat32(value) then
		return float32
	end

	return float64
end

local codecsById: { [number]: codec } = {}

local orderedCodecs: { codec } = {
	{
		id = 0,
		matches = function(value)
			return value == nil
		end,
		read = function(_b, _cursor)
			return nil, 0
		end,
		write = function(_value) end,
	},
	{
		id = 1,
		matches = function(value)
			return typeof(value) == "boolean"
		end,
		read = function(b, cursor)
			return bool.read(b, cursor)
		end,
		write = function(value)
			bool.write(value :: boolean)
		end,
	},
	{
		id = 2,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == uint8
		end,
		read = function(b, cursor)
			return uint8.read(b, cursor)
		end,
		write = function(value)
			uint8.write(value :: number)
		end,
	},
	{
		id = 3,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == uint16
		end,
		read = function(b, cursor)
			return uint16.read(b, cursor)
		end,
		write = function(value)
			uint16.write(value :: number)
		end,
	},
	{
		id = 4,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == uint32
		end,
		read = function(b, cursor)
			return uint32.read(b, cursor)
		end,
		write = function(value)
			uint32.write(value :: number)
		end,
	},
	{
		id = 5,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == int8
		end,
		read = function(b, cursor)
			return int8.read(b, cursor)
		end,
		write = function(value)
			int8.write(value :: number)
		end,
	},
	{
		id = 6,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == int16
		end,
		read = function(b, cursor)
			return int16.read(b, cursor)
		end,
		write = function(value)
			int16.write(value :: number)
		end,
	},
	{
		id = 7,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == int32
		end,
		read = function(b, cursor)
			return int32.read(b, cursor)
		end,
		write = function(value)
			int32.write(value :: number)
		end,
	},
	{
		id = 8,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return numberCodecFor(value :: number) == float32
		end,
		read = function(b, cursor)
			return float32.read(b, cursor)
		end,
		write = function(value)
			float32.write(value :: number)
		end,
	},
	{
		id = 9,
		matches = function(value)
			if typeof(value) ~= "number" then
				return false
			end

			return true
		end,
		read = function(b, cursor)
			return float64.read(b, cursor)
		end,
		write = function(value)
			float64.write(value :: number)
		end,
	},
	{
		id = 10,
		matches = function(value)
			return typeof(value) == "string"
		end,
		read = function(b, cursor)
			return stringType.read(b, cursor)
		end,
		write = function(value)
			stringType.write(value :: string)
		end,
	},
	{
		id = 12,
		matches = function(value)
			return typeof(value) == "Vector2"
		end,
		read = function(b, cursor)
			return vec2.read(b, cursor)
		end,
		write = function(value)
			vec2.write(value :: Vector2)
		end,
	},
	{
		id = 13,
		matches = function(value)
			return typeof(value) == "Vector3"
		end,
		read = function(b, cursor)
			return vec3.read(b, cursor)
		end,
		write = function(value)
			vec3.write(value :: Vector3)
		end,
	},
	{
		id = 14,
		matches = function(value)
			return typeof(value) == "Color3"
		end,
		read = function(b, cursor)
			return color3.read(b, cursor)
		end,
		write = function(value)
			color3.write(value :: Color3)
		end,
	},
	{
		id = 15,
		matches = function(value)
			return typeof(value) == "CFrame"
		end,
		read = function(b, cursor)
			return cframe.read(b, cursor)
		end,
		write = function(value)
			cframe.write(value :: CFrame)
		end,
	},
	{
		id = 17,
		matches = function(_value)
			return true
		end,
		read = function(b, cursor)
			return unknown.read(b, cursor)
		end,
		write = function(value)
			unknown.write(value)
		end,
	},
}

for _, codecData in orderedCodecs do
	codecsById[codecData.id] = codecData
end

local function getCodecFromValue(value: unknown): codec
	for _, codecData in orderedCodecs do
		if codecData.matches(value) then
			return codecData
		end
	end

	error("No codec found for auto dataType")
end

return function(): types.dataTypeInterface<unknown>
	return {
		write = function(value: unknown)
			local codecData = getCodecFromValue(value)

			writeU8(codecData.id)
			codecData.write(value)
		end,

		read = function(b: buffer, cursor: number)
			local dataTypeId = buffer.readu8(b, cursor)
			local codecData = codecsById[dataTypeId]

			if not codecData then
				error(`auto dataType does not support type id {dataTypeId}`)
			end

			local value, length = codecData.read(b, cursor + 1)

			return value, length + 1
		end,
	}
end
