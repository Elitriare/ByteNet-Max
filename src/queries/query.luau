--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)

local moduleRunContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

return function(properties: types.queryProperties<types.dataTypeInterface<any>>, id: number)
	local listeners = {}
	
	local clientInvokeFunction: (id: number, writer: (value: any) -> (), data: any) -> any = client.invoke
	
	local writer = properties.request.write
	
	local exported = {}
	exported.reader = properties.request.read
	
	if moduleRunContext == "client" then
		function exported.invoke(data)
			local response = clientInvokeFunction(id, writer, data)
			
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
	end
	
	function exported.getListeners()
		return listeners
	end
	
	return exported
end