# API overview

The public module exports three definition functions and a set of composable data types.

| Export | Purpose |
| --- | --- |
| [`defineNamespace`](namespace.md) | Group and initialize packets and queries |
| [`definePacket`](packet.md) | Define a one-way typed message |
| [`defineQuery`](query.md) | Define a typed request and response |
| [Data types](data-types.md) | Describe serialized values |

## Typical definition

```lua
return ByteNetMax.defineNamespace("Game", function()
	return {
		packets = {
			StatusChanged = ByteNetMax.definePacket({
				value = ByteNetMax.string,
			}),
		},
		queries = {
			GetStatus = ByteNetMax.defineQuery({
				request = ByteNetMax.nothing,
				response = ByteNetMax.string,
			}),
		},
	}
end)
```

All functions use dot syntax:

```lua
Packet.send(Data)
Packet.listen(Callback)
```

Do not use colon syntax (`Packet:send(Data)`).
