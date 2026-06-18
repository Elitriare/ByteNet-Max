# Required initialization

ByteNet Max must initialize the **same shared namespace module** on both the server and client. This is required before packets or queries can communicate.

!!! danger "Require it twice: once per runtime"
    A server Script must require your shared namespace module, and a LocalScript must require that same module. The server should initialize first so it can publish the packet, query, and struct mappings that the client reads.

## 1. Keep definitions in `ReplicatedStorage`

```text
ReplicatedStorage
├── ByteNetMax
└── Network.luau
ServerScriptService
└── Network.server.luau
StarterPlayer
└── StarterPlayerScripts
    └── Network.client.luau
```

```lua title="ReplicatedStorage/Network.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.ByteNetMax)

return ByteNetMax.defineNamespace("Game", function()
	return {
		packets = {
			Ready = ByteNetMax.definePacket({
				value = ByteNetMax.bool,
			}),
		},
	}
end)
```

If the namespace uses packets, return a `packets` table. If it uses queries, return a `queries` table. A namespace can return both.

## 2. Initialize the server

```lua title="ServerScriptService/Network.server.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.packets.Ready.listen(function(IsReady, Player)
	print(Player.Name, IsReady)
end)
```

Run this during server startup—not only after a player performs an action.

## 3. Initialize the client

```lua title="StarterPlayerScripts/Network.client.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.packets.Ready.send(true)
```

The client reads the metadata established by the server and builds matching local packet/query objects.

## What failure looks like

Missing or mismatched initialization can cause:

- A namespace failing while the client starts
- An invalid or missing packet/query ID
- A “no readable entity” error
- Data being decoded with the wrong schema
- Networking that works inconsistently because of startup order

When debugging these symptoms, first confirm that the server initializes the shared module, the client requires the exact same instance, and both sides use the same deployed version.

!!! note "What “secure” means here"
    This setup establishes ByteNet Max's controlled shared network mapping; it is not encryption or authentication. You must still validate all client requests on the server.

[Create your first packet](first-packet.md){ .md-button .md-button--primary }
