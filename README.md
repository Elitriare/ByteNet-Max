<div align="center"><h1><b>ByteNet Max</b></h1></div>
<div align="center"><h2><b>An upgraded buffer-based networking system</b></h2></div>
<div align="center"><a href="https://github.com/Elitriare/ByteNet-Max">GitHub</a> | <a href="https://wally.run/package/elitriare/bytenet-max?version=0.1.8">Wally</a> | <a href="https://create.roblox.com/store/asset/81428213632345/ByteNet-Max">Roblox Creator Store</a></div>

ByteNet Max is an upgraded version of @ffrostfall's [ByteNet](https://devforum.roblox.com/t/bytenet-advanced-networking-library-w-buffer-serialization-strict-luau-absurd-optimization-and-rbxts-support-043/2733365) which relies on strict type-checking to serialise your data into buffers before deserialising it on the other end, feeding it back to your Luau code. But what makes ByteNet Max different from ByteNet? ByteNet Max supports queries (RemoteFunctions) which are client to server requests for data. This brings you an extremely optimised experience for RemoteFunctions, using minimal data to increase send and receive speeds. ByteNet Max lives up to ByteNet's idea of making networking simple, easy and quick. The API is simple and minimalistic, helping you grasp the concepts of ByteNet Max pretty quickly!

<h3><b>Installation</b></h3> 

Get [ByteNet Max](https://create.roblox.com/store/asset/81428213632345/ByteNet-Max) on the Roblox Creator Store, or on [Wally](https://wally.run/package/elitriare/bytenet-max?version=0.1.8) **(WARNING: v1.0.0 is the FIRST version of ByteNet Max, due to an error I made. The latest version is always the one shown on the title of this post)**!

<h3><b>Performance</b></h3> 

ByteNet Max lives up to the standards of ByteNet, performing incredibly well compared to other networking libraries such as BridgeNet2. The conversion to a buffer reduces memory usage significantly, helping optimise and speed up data transfer.

<h3><b>Documentation</b></h3> 

ByteNet Max follows the same architecture as ByteNet, hence the documentation for RemoteEvents (packets) is the exact same and can be found here: [Documentation](https://ffrostfall.github.io/ByteNet/api/functions/definePacket/).

However, it adds a new system named **queries**. This is the ByteNet equivalent of a RemoteFunction. To begin, you can create a ModuleScript to define a namespace under which your packets and queries will be held:
```lua
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
```lua
local QueryModule = require(path.to.QueryModule)

local Coins = QueryModule.queries.GetCoins.invoke({
	message = "Can I please get the coins value?"
})

print(Coins)
```

In a server script, you can receive the query and return the appropriate information, like so:
```lua
local QueryModule = require(path.to.QueryModule)

QueryModule.queries.GetCoins.listen(function(data, player)	
    print(data.message) -- prints "Can I please get the coins value?"
	return {coins = player.leaderstats.Coins.Value}
end)
```

If you want to disconnect the listener in the future, you can assign the function to a variable:
```lua
local QueryModule = require(path.to.QueryModule)
local Listener 

Listener = QueryModule.queries.GetCoins.listen(function(data, player)	
    print(data.message) -- prints "Can I please get the coins value?"
	return {coins = player.leaderstats.Coins.Value}
end)

Listener() -- disconnects listener
```

The above function works with **packets** too!

It's that simple!

Packets & Queries can co-exist under the same namespace, just make sure you define the packets and queries table in defineNamespace. If you don't require packets, you can leave it out and just define the queries table, and vice versa.

<b>IMPORTANT:</b> <u><b><i>You must require the ModuleScript you created on both the server and client! This is to initialise server side & client side dependencies for a secure network.</b></i></u>

<h2>Some extra functions</h2>

ByteNet Max also adds extra functions for both packets & queries for better control over your code. You can now use .listenOnce() and .disconnectAll() to call a function once or disable all callbacks connected to a packet/query (equivalent to the :Disconnect() and :Once() functions from Roblox)

Using the example above, .listenOnce() is used the same way as .listen() : 
```lua
local QueryModule = require(path.to.QueryModule)

QueryModule.queries.GetCoins.listenOnce(function(data, player)	 -- this callback only runs once, before disconnecting.
    print(data.message) -- prints "Can I please get the coins value?"
	return {coins = player.leaderstats.Coins.Value}
end)
```

The .disconnectAll() function can be used to completely erase every callback created through .listen():
```lua
local QueryModule = require(path.to.QueryModule)

QueryModule.queries.GetCoins.disconnectAll() -- disconnects all callbacks
```

<h3><b>Contact</b></h3> 

Contact me on [Twitter](https://x.com/Elitriare) or Discord (username: elitriare), or just on this thread to report bugs or request features. I haven't fully tested this across different types of experiences, so your ***feedback*** is extremely useful!

This project is open-source.
