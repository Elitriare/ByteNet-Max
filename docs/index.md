---
hide:
  - navigation
  - toc
---

# Networking that stays understandable

ByteNet Max is a typed, buffer-based networking library for Roblox. Define each message once, share that definition between the server and client, and use **packets** for events or **queries** for request/response calls.

[Build your first packet](getting-started/first-packet.md){ .md-button .md-button--primary }
[Install ByteNet Max](getting-started/installation.md){ .md-button }

<div class="critical-setup" markdown>

### :material-connection: Required: initialize on the server **and** client

The same shared namespace ModuleScript must be required by a server Script and a LocalScript. The server should initialize first. Without both sides, ByteNet Max cannot establish matching packet, query, and struct mappings, and networking will fail.

[See the required setup →](getting-started/initialization.md)

</div>

<div class="feature-grid" markdown>

<div class="feature-card" markdown>

## :material-lightning-bolt: Packets

Send one-way messages through reliable or unreliable channels. ByteNet Max batches packet traffic once per frame.

[Learn packets](guides/packets.md)

</div>

<div class="feature-card" markdown>

## :material-swap-horizontal: Queries

Send a typed request from a client and receive a typed response from the server—without manually creating a `RemoteFunction`.

[Learn queries](guides/queries.md)

</div>

<div class="feature-card" markdown>

## :material-code-braces: Shared definitions

Keep packet and query schemas in a shared ModuleScript. The same schema gives both sides a consistent wire format.

[Understand namespaces](api/namespace.md)

</div>

</div>

## The complete shape

```lua title="ReplicatedStorage/Network.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.Packages.ByteNetMax)

return ByteNetMax.defineNamespace("Game", function()
	return {
		packets = {
		ShowToast = ByteNetMax.definePacket({
			value = ByteNetMax.struct({
				Message = ByteNetMax.string,
			}),
		}),
		},
		queries = {
			GetCoins = ByteNetMax.defineQuery({
				request = ByteNetMax.nothing,
				response = ByteNetMax.uint32,
			}),
		},
	}
end)
```

```lua title="ServerScriptService/Network.server.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.queries.GetCoins.listen(function(_, Player)
	return Player:GetAttribute("Coins") or 0
end)

Network.packets.ShowToast.sendTo({ Message = "Welcome!" }, game.Players:GetPlayers()[1])
```

```lua title="StarterPlayerScripts/Network.client.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.packets.ShowToast.listen(function(Data)
	print(Data.Message)
end)

local Coins = Network.queries.GetCoins.invoke(nil)
print(`You have {Coins} coins`)
```

!!! danger "Do not skip network initialization"
    The server and client must both require the same namespace ModuleScript. Put it in `ReplicatedStorage`, require it from a server Script first, and require it again from a LocalScript. [See the exact setup](getting-started/initialization.md).

## Pick the right tool

| You need to… | Use | Example |
| --- | --- | --- |
| Notify the server or a client | Packet | Equip an item, show an effect |
| Broadcast to several clients | Packet | Round state, announcement |
| Send frequent disposable state | Unreliable packet | Aim direction, cosmetic position |
| Ask the server for a result | Query | Fetch a profile summary |

ByteNet Max is based on [ByteNet](https://github.com/ffrostfall/ByteNet), but this documentation describes **ByteNet Max's current source and API**.
