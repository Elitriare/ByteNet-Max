<div align="center">

# ByteNet Max

Typed, buffer-based networking for Roblox—with packets for events and queries for request/response calls.

[Documentation](https://elitriare.github.io/ByteNet-Max/) · [Wally](https://wally.run/package/elitriare/bytenet-max) · [Creator Store](https://create.roblox.com/store/asset/81428213632345/ByteNet-Max)

</div>

## What it provides

- Typed buffer serialization for compact network payloads
- Reliable and unreliable packets
- Client-to-server queries with typed responses
- Frame-batched packet traffic
- Composable schemas for Roblox and Luau values

## Install with Wally

```toml
[dependencies]
ByteNetMax = "elitriare/bytenet-max@0.2.7"
```

Check the [Wally package](https://wally.run/package/elitriare/bytenet-max) for the latest published version.

## Minimal example

> [!IMPORTANT]
> The shared namespace ModuleScript must be required on both the server and client, with the server initializing first. See [Required initialization](https://elitriare.github.io/ByteNet-Max/getting-started/initialization/).

Define networking once in a shared ModuleScript:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.Packages.ByteNetMax)

return ByteNetMax.defineNamespace("Game", function()
	return {
		packets = {
			Announcement = ByteNetMax.definePacket({
				value = ByteNetMax.string,
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

Require that shared module on both the server and client. See the [getting started guide](https://elitriare.github.io/ByteNet-Max/getting-started/installation/) for the complete setup.

## Documentation

The dedicated documentation covers:

- [Your first packet](https://elitriare.github.io/ByteNet-Max/getting-started/first-packet/)
- [Your first query](https://elitriare.github.io/ByteNet-Max/getting-started/first-query/)
- [Packet API](https://elitriare.github.io/ByteNet-Max/api/packet/)
- [Query API](https://elitriare.github.io/ByteNet-Max/api/query/)
- [Data types](https://elitriare.github.io/ByteNet-Max/api/data-types/)
- [Security and limits](https://elitriare.github.io/ByteNet-Max/guides/security/)

## License

ByteNet Max is available under the [MIT License](LICENSE).
