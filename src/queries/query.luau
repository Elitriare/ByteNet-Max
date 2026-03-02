--!native
--!optimize 2
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local client = require(script.Parent.Parent.process.client)

local moduleRunContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

return function(properties: types.queryProperties<types.dataTypeInterface<any>, types.dataTypeInterface<any>>, id: number)
	local listeners: {types.QueryListener<any, any>} = {}
	
	local clientInvokeFunction: (id: number, requestWriter: (value: any) -> (), data: any) -> any = client.invoke
	
	local requestWriter = properties.request.write
	
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
		-- use a OnceCallback for this still
		local runningThread = coroutine.running()
		table.insert(listeners, {
			Callback = function(data, player)
				print(data)
				task.spawn(runningThread, data, player)
			end,
			OnceCallback = true
		})
		
		return coroutine.yield()
	end
	
	function exported.listen(callback)
		local listener = {
			Callback = callback,
			OnceCallback = false	
		}
		table.insert(listeners, listener)

		return function()
			exported.disconnect(listener)
		end
	end
	
	function exported.disconnectAll()
		table.clear(listeners)
	end
	
	function exported.disconnect(listener)
		-- Ensure the index isn't nil to avoid removing arbitrary listeners
		local index = table.find(listeners, listener)
		if index ~= nil then
			table.remove(listeners, index)
		else
			warn('Query listener was already disconnected.')
		end
	end
	
	function exported.listenOnce(callback)
		local listener = {
			Callback = callback,
			OnceCallback = true	
		}
		table.insert(listeners, listener)

		return function()
			exported.disconnect(listener)
		end
	end
	
	function exported.getListeners()
		return listeners
	end
	
	return exported
end