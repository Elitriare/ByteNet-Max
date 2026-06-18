# Your first query

A query is a client-to-server request that returns a response. Use it when the caller cannot continue without a server result.

!!! important "Before you start"
    Complete [Required initialization](initialization.md) first. Your shared namespace module must be required on both the server and client.

## 1. Define request and response types

```lua title="ReplicatedStorage/Network.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.ByteNetMax)

return ByteNetMax.defineNamespace("PlayerData", function()
	return {
		queries = {
			GetItemCount = ByteNetMax.defineQuery({
				request = ByteNetMax.struct({
					ItemId = ByteNetMax.string,
				}),
				response = ByteNetMax.uint16,
			}),
		},
	}
end)
```

## 2. Return the response on the server

```lua title="ServerScriptService/Network.server.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

Network.queries.GetItemCount.listen(function(Request, Player)
	-- Replace this with a lookup in server-owned player data.
	local Inventory = GetInventoryFor(Player)
	return Inventory[Request.ItemId] or 0
end)
```

The returned value must match the query's `response` data type.

## 3. Invoke it on the client

```lua title="StarterPlayerScripts/Network.client.luau"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)

local PotionCount = Network.queries.GetItemCount.invoke({
	ItemId = "HealthPotion",
})

print(`Potions: {PotionCount}`)
```

`invoke` yields until the server responds. Do not invoke a query every frame or use one for fire-and-forget notifications.

!!! tip "No request data?"
    Use `request = ByteNetMax.nothing`, then call `invoke(nil)`.

[Understand query behavior](../guides/queries.md){ .md-button .md-button--primary }
