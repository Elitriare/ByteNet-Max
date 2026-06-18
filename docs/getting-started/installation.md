# Installation

Install ByteNet Max from Wally or the Roblox Creator Store. Wally is the recommended option for projects already managed with Rojo.

## Wally

Add ByteNet Max to `wally.toml`:

```toml
[dependencies]
ByteNetMax = "elitriare/bytenet-max@0.2.7"
```

Install the package:

```shell
wally install
```

Then require the installed ModuleScript. The exact path depends on your Rojo project:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetMax = require(ReplicatedStorage.Packages.ByteNetMax)
```

Check the [Wally package](https://wally.run/package/elitriare/bytenet-max) for the latest published version before pinning it.

## Roblox Creator Store

Get [ByteNet Max from the Creator Store](https://create.roblox.com/store/asset/81428213632345/ByteNet-Max), insert it into your experience, and move the module to a shared location such as `ReplicatedStorage`.

```text
ReplicatedStorage
├── ByteNetMax
└── Network
```

## Project layout

A small project normally needs three scripts:

```text
ReplicatedStorage
├── ByteNetMax
└── Network.luau             # Shared definitions
ServerScriptService
└── Network.server.luau      # Server listeners and sends
StarterPlayer
└── StarterPlayerScripts
    └── Network.client.luau  # Client listeners and sends
```

Both runtime sides must require `Network.luau`. The server should initialize its networking code during startup so namespace metadata exists before the client reads it.

## Next step

[Create your first packet](first-packet.md){ .md-button .md-button--primary }
