# Packets

Packets are typed, one-way messages. Choose them when the sender does not need a direct return value.

## Define a packet

```lua
UpdateHealth = ByteNetMax.definePacket({
	value = ByteNetMax.struct({
		Current = ByteNetMax.uint16,
		Maximum = ByteNetMax.uint16,
	}),
})
```

The `value` field is required. `reliabilityType` is optional and defaults to `"reliable"`.

## Client methods

### `send(data)`

Queues data for the server.

```lua
Network.packets.RequestAbility.send({ AbilityId = "Dash" })
```

The server receives the sending `Player` as the callback's second argument.

## Server methods

### `sendTo(data, player)`

Sends to one player. Data is the first argument.

```lua
Network.packets.UpdateHealth.sendTo({
	Current = 75,
	Maximum = 100,
}, Player)
```

### `sendToList(data, players)`

Sends the same data to each player in an array.

```lua
Network.packets.RoundState.sendToList({ State = "Active" }, TeamPlayers)
```

### `sendToAll(data)`

Broadcasts to every connected player.

```lua
Network.packets.Announcement.sendToAll({ Text = "Round starting" })
```

### `sendToAllExcept(data, player)`

Broadcasts to everyone except one player.

```lua
Network.packets.PlayerMoved.sendToAllExcept(MovementData, MovingPlayer)
```

## Listening

These methods exist on both sides.

### `listen(callback)`

Registers a persistent callback and returns a disconnect function.

```lua
local Disconnect = Network.packets.Announcement.listen(function(Data)
	print(Data.Text)
end)

Disconnect()
```

The callback receives `(Data, Player)` on the server and `(Data)` on the client.

### `listenOnce(callback)`

Runs the callback for the next received packet, then removes it. It also returns a disconnect function.

```lua
Network.packets.Ready.listenOnce(function(Data, Player)
	print(Player, Data)
end)
```

### `wait()`

Yields the current thread until the next packet arrives and returns the same values a callback receives.

```lua
local Data, Player = Network.packets.Ready.wait()
```

### `disconnectAll()`

Removes every listener attached to that packet in the current runtime.

```lua
Network.packets.Ready.disconnectAll()
```

!!! warning
    `disconnectAll()` affects listeners created by other scripts too. Prefer the disconnect function returned by `listen` when you own only one listener.

## Reliable and unreliable packets

```lua
AimDirection = ByteNetMax.definePacket({
	value = ByteNetMax.vec3,
	reliabilityType = "unreliable",
})
```

Use `"reliable"` for state changes that must arrive. Use `"unreliable"` for frequent updates where a newer value replaces an older one. See [Reliability and batching](reliability.md).
