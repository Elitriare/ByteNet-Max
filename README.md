<div align="center"><h1><b>ByteNet Max</b></h1></div>
<div align="center"><h2><b>An upgraded buffer-based networking system</b></h2></div>

ByteNet Max is an upgraded version of @ffrostfall's [ByteNet](https://devforum.roblox.com/t/bytenet-advanced-networking-library-w-buffer-serialization-strict-luau-absurd-optimization-and-rbxts-support-043/2733365) which relies on strict type-checking to serialise your data into buffers before deserialising it on the other end, feeding it back to your Luau code. But what makes ByteNet Max different from ByteNet? ByteNet Max supports queries (RemoteFunctions) which are client to server requests for data. This brings you an extremely optimised experience for RemoteFunctions, using minimal data to increase send & receive speeds. ByteNet Max lives up to ByteNet's idea of making networking simple, easy and quick. The API is simple an minimalistic, helping you grasp the concepts of ByteNet Max pretty quickly!

<h3><b>Installation</b></h3> 

Get [ByteNet Max](https://create.roblox.com/store/asset/81428213632345/ByteNet-Max) on the Roblox Creator Store!

<h3><b>Performance</b></h3> 

ByteNet Max lives up to the standards of ByteNet, performing incredibly well compared to other networking libraries such as BridgeNet2. The conversion to a buffer reduces memory usage significantly, helping optimise and speed up data transfer.

<h3><b>Documentation</b></h3> 

ByteNet Max follows the same architecture as ByteNet, hence the documentation for RemoteEvents (packets) is the exact same and can be found here: [Documentation](https://ffrostfall.github.io/ByteNet/api/functions/definePacket/).

However, it adds a new system named **queries**. This is the ByteNet equivalent of a RemoteFunction. To begin, you can create a ModuleScript to define a namespace under which your packets and queries will be held:
```luau
local ByteNetMax = require(path.to.ByteNetMax)

return ByteNetMax.defineNamespace("PlayerData", function()
    return {
       packets = {}, -- not necessary to include this table if there's no values in it.
       queries = {
		GetCoins = ByteNetMax.defineQuery({
			request = ByteNetMax.struct({
				message = ByteNetMax.string
			}),
			response = ByteNetMax.struct({
				coins = ByteNetMax.uint8
			})
		})
	},		
    }
end)
```

Then, in a local script, you can invoke the query like so:
```luau
local QueryModule = require(path.to.QueryModule)

local Coins = QueryModule.queries.GetCoins.invoke({
	message = "Can I please get the coins value?"
})

print(Coins)
```

In a server script, you can receive the query and return the appropriate information, like so:
```luau
local QueryModule = require(path.to.QueryModule)

QueryModule.queries.GetCoins.listen(function(data, player)	
	print(data.message) -- prints "Can I please get the coins value?"
	return player.leaderstats.Coins.Value
end)
```

It's that simple!

Packets & Queries can co-exist under the same namespace, just make sure you define the packets and queries table in defineNamespace. If you don't require packets, you can leave it out and just define the queries table, and vice versa.

<b>IMPORTANT:</b> You must require the ModuleScript you created on both the server and client! This is to initialise server side & client side dependencies for a secure network.

<h3><b>Contact</b></h3> 

Contact me on [Twitter](https://x.com/Elitriare) or Discord (username: elitriare), or just in this thread to report bugs or request features. I haven't fully tested this across different types of experiences, so your ***feedback*** is extremely useful!

This project is open-source.
