# Reliability and batching

## Reliable packets

Reliable packets use a Roblox `RemoteEvent` and are the default.

```lua
InventoryChanged = ByteNetMax.definePacket({
	value = InventoryChangeType,
	reliabilityType = "reliable",
})
```

Use reliable delivery for messages where losing one update would make state incorrect:

- Inventory and economy changes
- Round transitions
- Confirmed actions
- UI state that is not continuously refreshed

## Unreliable packets

Unreliable packets use `UnreliableRemoteEvent`.

```lua
AimDirection = ByteNetMax.definePacket({
	value = ByteNetMax.vec3,
	reliabilityType = "unreliable",
})
```

Use unreliable delivery when the newest update matters and an older one can be discarded:

- Aim direction
- Cosmetic transforms
- Rapid, replaceable effects
- Non-authoritative telemetry

Never use unreliable delivery for purchases, damage decisions, inventory changes, or any state transition that must arrive.

## Frame batching

ByteNet Max queues packet writes and flushes its reliable and unreliable channels on `RunService.Heartbeat`. Multiple sends in one frame can share a single transport call.

This means:

- `send` queues a packet; it does not immediately perform a remote call.
- Bursty traffic in one frame benefits from batching.
- You should still avoid unnecessary high-frequency sends.

Queries use the query transport and wait for a response; they are not a replacement for packet streams.
