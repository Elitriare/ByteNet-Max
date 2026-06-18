# `defineNamespace`

Groups packet and query definitions and coordinates their IDs between the server and clients.

```lua
ByteNetMax.defineNamespace(Name, DefinitionCallback)
```

## Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `Name` | `string` | Stable, unique namespace name |
| `DefinitionCallback` | `() -> table` | Returns optional `packets` and `queries` tables |

## Returns

```lua
{
	packets = { [string]: Packet },
	queries = { [string]: Query },
}
```

## Example

```lua
local Network = ByteNetMax.defineNamespace("Chat", function()
	return {
		packets = {
			SendMessage = ByteNetMax.definePacket({
				value = ByteNetMax.string,
			}),
		},
		queries = {},
	}
end)
```

The empty tables are optional. A packet-only namespace may omit `queries`, and a query-only namespace may omit `packets`.

!!! important
    Define a namespace in one shared ModuleScript and require that module on both server and client. Do not maintain two hand-written copies of the schema.
