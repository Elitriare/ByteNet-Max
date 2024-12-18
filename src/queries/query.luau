--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)

local moduleRunContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

return function(properties: types.queryProperties<types.dataTypeInterface<any>, types.dataTypeInterface<any>>, id: number)
	local listeners = {}
	
	local clientInvokeFunction: (id: number, requestWriter: (value: any) -> (), data: any) -> any = client.invoke
	
	local requestWriter = properties.request.write
	local responseWriter = properties.response.write
	
	local exported = {}
	exported.requestReader = properties.request.read
	exported.responseReader = properties.response.read
	exported.responseWriter = properties.response.write
	
	if moduleRunContext == "client" then
		function exported.invoke(data)
			local response = clientInvokeFunction(id, requestWriter, data)
			
			return response
		end
	end
	
	function exported.wait()
		local index: number
		
		local runningThread = coroutine.running()
		table.insert(listeners, function(data, player)
			print(data)
			task.spawn(runningThread, data, player)
			
			table.remove(listeners, index)
		end)
		
		index = #listeners
		
		return coroutine.yield()
	end
	
	function exported.listen(callback)
		table.insert(listeners, callback)
		
		return function()
			exported.disconnect(callback)
		end
	end
	
	function exported.disconnectAll()
		table.clear(listeners)
	end
	
	function exported.disconnect(callback)
		table.remove(listeners, table.find(listeners, callback))
	end
	
	function exported.listenOnce(callback)
		table.insert(listeners, {
			["OnceCallback"] = callback	
		})
	end
	
	function exported.getListeners()
		return listeners
	end
	
	return exported
end