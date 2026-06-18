# Your first packet

A packet is a one-way message. In this example, the client tells the server which action it requested.

## 1. Define it once

Create a shared ModuleScript:

```lua title="ReplicatedStorage/Network.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.ByteNetMax)

return ByteNetMax.defineNamespace("Tutorial", function()
	return {
		packets = {
			RequestAction = ByteNetMax.definePacket({
				value = ByteNetMax.struct({
					Action = ByteNetMax.string,
				}),
			}),
		},
	}
end)
```

`value` is the packet's schema. Sending anything that does not match this shape can fail during serialization.

## 2. Listen on the server

```lua title="ServerScriptService/Network.server.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.packets.RequestAction.listen(function(Data, Player)
	print(`{Player.Name} requested {Data.Action}`)
end)
```

On the server, packet callbacks receive `(Data, Player)`.

## 3. Send from the client

```lua title="StarterPlayerScripts/Network.client.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.packets.RequestAction.send({
	Action = "Dash",
})
```

The client uses `send`. The server uses methods such as `sendTo` and `sendToAll`.

!!! warning "Packets are not security boundaries"
    A client can request any action at any time. Validate permissions, cooldowns, distance, ownership, and all other authoritative state on the server.

[See every packet method](../guides/packets.md){ .md-button }
[Create a query](first-query.md){ .md-button }
