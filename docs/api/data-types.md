# Data types

Data types describe how ByteNet Max serializes values. Primitive exports are values; constructors such as `struct`, `array`, `map`, and `optional` are functions.

## Numbers

| Type | Value | Encoded size | Range / precision |
| --- | --- | ---: | --- |
| `uint8` | Integer | 1 byte | 0 to 255 |
| `uint16` | Integer | 2 bytes | 0 to 65,535 |
| `uint32` | Integer | 4 bytes | 0 to 4,294,967,295 |
| `int8` | Integer | 1 byte | −128 to 127 |
| `int16` | Integer | 2 bytes | −32,768 to 32,767 |
| `int32` | Integer | 4 bytes | −2,147,483,648 to 2,147,483,647 |
| `float32` | Number | 4 bytes | 32-bit floating point |
| `float64` | Number | 8 bytes | 64-bit floating point |

```lua
Score = ByteNetMax.uint32
Temperature = ByteNetMax.float32
```

## Roblox and primitive values

| Type | Luau value | Encoded size | Notes |
| --- | --- | ---: | --- |
| `bool` | `boolean` | 1 byte | `0` or `1` |
| `string` | `string` | 2-byte length + data | Length prefix is `uint16` |
| `vec2` | `Vector2` | 8 bytes | Two float32 components |
| `vec3` | `Vector3` | 12 bytes | Three float32 components |
| `color3` | `Color3` | 3 bytes | RGB channels quantized to 8 bits |
| `cframe` | `CFrame` | 24 bytes | Position and axis-angle rotation as float32s |
| `buff` | `buffer` | 4-byte length + data | Copies the buffer payload |
| `inst` | `Instance?` | 2-byte reference index | Uses the transport's reference list |
| `unknown` | `unknown` | 2-byte reference index | Uses the transport's reference list |
| `nothing` | `nil` | 0 bytes | Useful for empty query requests |

## `struct(fields)`

Serializes a fixed dictionary shape.

```lua
local PlayerState = ByteNetMax.struct({
	Health = ByteNetMax.uint16,
	Position = ByteNetMax.vec3,
	Name = ByteNetMax.string,
})
```

The encoded size is the sum of its field sizes.

## `array(valueType)`

Serializes a sequential array. Its count uses a 2-byte `uint16` prefix.

```lua
local Tags = ByteNetMax.array(ByteNetMax.string)
```

## `map(keyType, valueType)`

Serializes a dictionary as key/value pairs. Its count uses a 2-byte `uint16` prefix.

```lua
local Scores = ByteNetMax.map(ByteNetMax.string, ByteNetMax.uint32)
```

## `optional(valueType)`

Serializes a 1-byte presence marker, followed by the value when it is not `nil`.

```lua
local Subtitle = ByteNetMax.optional(ByteNetMax.string)
```

## `auto`

Detects the value's type at runtime and adds a 1-byte type marker. Integers use the smallest fitting numeric codec; exact float32 values use `float32`, otherwise `float64` is used.

Supported direct codecs are `nil`, boolean, number, string, `Vector2`, `Vector3`, `Color3`, and `CFrame`. Other values use the reference-based `unknown` codec.

## Aliases

| Alias | Equivalent type |
| --- | --- |
| `playerName` | `string` |
| `playerIdentifier` | `uint8` |

These are compatibility aliases in the current public module. For Roblox `UserId` values, prefer a type with sufficient range such as `uint32`.
