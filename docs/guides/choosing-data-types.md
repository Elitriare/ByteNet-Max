# Choosing data types

Choose the narrowest type that covers the values you expect. Smaller types reduce bandwidth and make the schema explain itself.

## A practical schema

```lua
ByteNetMax.struct({
	UserId = ByteNetMax.uint32,
	DisplayName = ByteNetMax.string,
	Position = ByteNetMax.vec3,
	Health = ByteNetMax.uint16,
	IsAlive = ByteNetMax.bool,
	Title = ByteNetMax.optional(ByteNetMax.string),
})
```

## Numbers

- Use `uint8` for integers from 0 to 255.
- Use `uint16` for integers from 0 to 65,535.
- Use `uint32` for larger non-negative integers.
- Use signed integers when negatives are valid.
- Use `float32` for most decimal gameplay values.
- Use `float64` only when you need its additional precision.

## Collections

Use `array(type)` for sequential lists and `map(keyType, valueType)` for dictionaries.

```lua
Inventory = ByteNetMax.array(ByteNetMax.struct({
	ItemId = ByteNetMax.string,
	Amount = ByteNetMax.uint16,
}))

Cooldowns = ByteNetMax.map(ByteNetMax.string, ByteNetMax.float32)
```

Arrays and maps store their count as a `uint16`, so one value can contain at most 65,535 entries.

## Optional values

`optional(type)` adds a one-byte presence marker:

```lua
Target = ByteNetMax.optional(ByteNetMax.inst)
```

## `auto`

`auto` writes a one-byte type marker and selects a codec at runtime. It supports `nil`, booleans, numbers, strings, `Vector2`, `Vector3`, `Color3`, and `CFrame`; other values fall back to the reference-based `unknown` codec.

```lua
DebugValue = ByteNetMax.definePacket({
	value = ByteNetMax.auto,
})
```

Use `auto` for prototypes, debugging, or intentionally mixed values. Prefer explicit schemas for production traffic because they are easier to review and avoid a per-value type tag.

## Instances and unknown values

`inst` and `unknown` use a reference list alongside the serialized buffer. Use `inst` when the value should be an `Instance`; use `unknown` only when a stable explicit schema is not possible.

!!! tip
    If a payload has a known shape, a `struct` of explicit types is normally the best choice.
