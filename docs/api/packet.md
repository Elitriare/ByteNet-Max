# `definePacket`

Defines a typed, one-way message.

```lua
ByteNetMax.definePacket({
	value = DataType,
	reliabilityType = "reliable", -- optional
})
```

## Properties

| Property | Required | Description |
| --- | --- | --- |
| `value` | Yes | Data type used to serialize the packet payload |
| `reliabilityType` | No | `"reliable"` (default) or `"unreliable"` |

## Methods

| Method | Runtime | Returns | Description |
| --- | --- | --- | --- |
| `send(data)` | Client | `nil` | Queues data for the server |
| `sendTo(data, player)` | Server | `nil` | Queues data for one client |
| `sendToList(data, players)` | Server | `nil` | Queues data for each listed client |
| `sendToAll(data)` | Server | `nil` | Queues data for all clients |
| `sendToAllExcept(data, player)` | Server | `nil` | Queues data for all clients except one |
| `listen(callback)` | Both | Disconnect function | Adds a persistent listener |
| `listenOnce(callback)` | Both | Disconnect function | Adds a one-use listener |
| `wait()` | Both | Received values | Yields until the next packet |
| `disconnectAll()` | Both | `nil` | Removes all listeners for this packet |

On the server, listeners receive `(Data, Player)`. On the client, listeners receive `(Data)`.

See the [Packets guide](../guides/packets.md) for complete examples.
