# Migration from ByteNet

ByteNet Max began as a ByteNet fork, but projects should use ByteNet Max's own package and documentation.

## Update the dependency

```toml
[dependencies]
ByteNetMax = "elitriare/bytenet-max@0.2.7"
```

Check the [Wally package](https://wally.run/package/elitriare/bytenet-max) for the current version.

## Update the require

```lua
local ByteNetMax = require(ReplicatedStorage.Packages.ByteNetMax)
```

## Keep packet definitions shared

The familiar namespace and packet model remains:

```lua
ByteNetMax.defineNamespace("Game", function()
	return {
		packets = {
			Example = ByteNetMax.definePacket({
				value = ByteNetMax.string,
			}),
		},
	}
end)
```

Review method signatures against the [packet API](../api/packet.md), especially `sendTo(Data, Player)`.

## Replace manual request/response remotes

ByteNet Max adds queries:

```lua
GetValue = ByteNetMax.defineQuery({
	request = ByteNetMax.string,
	response = ByteNetMax.uint32,
})
```

Register the handler on the server with `listen`, then invoke it from the client with `invoke`.

## Review data types

Use the [ByteNet Max data type reference](../api/data-types.md) instead of assuming every upstream codec or API is identical.

## Test both runtime directions

Before shipping, verify:

- Client → server packet
- Server → client packet
- Reliable and unreliable traffic you use
- Query request and response
- Listener cleanup during player or UI lifecycle changes
