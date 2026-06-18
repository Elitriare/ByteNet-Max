# Security and limits

ByteNet Max serializes values according to your declared schemas. Your game must still validate meaning and authority.

## Validate every client request

For each client packet or query, verify relevant server-owned facts:

- Is this action allowed right now?
- Does the player own the item?
- Is the target close enough?
- Has the cooldown elapsed?
- Is the amount within a valid range?
- Can the player access the requested record?

```lua
Network.packets.BuyItem.listen(function(Request, Player)
	local Item = ItemCatalog[Request.ItemId]
	if not Item then
		return
	end

	if not EconomyService:CanAfford(Player, Item.Price) then
		return
	end

	EconomyService:Purchase(Player, Request.ItemId)
end)
```

Do not accept a price, reward, damage amount, or ownership flag just because it matches the declared data type.

## Inbound buffer limit

The server limits client buffers to the `MAX_BUFFER_SIZE` attribute on the ByteNet Max module. The default is 8,192 bytes. The same value is used as the per-client byte budget and refill rate per second.

Set the attribute before ByteNet Max starts if your experience needs a different limit:

```lua
ByteNetMaxModule:SetAttribute("MAX_BUFFER_SIZE", 16 * 1024)
local ByteNetMax = require(ByteNetMaxModule)
```

Increase this only after measuring a legitimate need. A larger value also permits more client-originated traffic.

## Keep payloads bounded

- Cap user-controlled string lengths before sending or processing them.
- Limit collection sizes.
- Prefer IDs over large repeated objects.
- Avoid sending state the receiver already has.
- Rate-limit expensive game actions separately from ByteNet Max's byte limiter.

## Keep the server authoritative

The client should request an action. The server should calculate the outcome and notify clients of the result.
