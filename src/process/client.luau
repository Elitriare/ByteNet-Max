local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local alloc = bufferWriter.alloc
local u8 = bufferWriter.u8
local load = bufferWriter.load

local waitingForResponse = false

local function onClientEvent(receivedBuffer, ref)
	read(receivedBuffer, ref)
end

-- Shared with: src/process/server.luau, src/process/read.luau (Infeasible to split this into another file)
local function create()
	return {
		cursor = 0,
		size = 256,
		references = {},
		buff = buffer.create(256),
	}
end

local function dump(channel: types.channelData): (buffer, { unknown }?)
	local cursor = channel.cursor
	local dumpBuffer = buffer.create(cursor)

	buffer.copy(dumpBuffer, 0, channel.buff, 0, cursor)

	return dumpBuffer, if #channel.references > 0 then channel.references else nil
end
-- No longer shared

local reliable: types.channelData = create()
local unreliable: types.channelData = create()
local funcs: {types.remoteFunctionChannel} = {}

local clientProcess = {}

function clientProcess.sendReliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	reliable = load(reliable)

	alloc(1)
	u8(id)
	writer(data)

	reliable = bufferWriter.export()
end

function clientProcess.sendUnreliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	unreliable = load(unreliable)

	alloc(1)
	u8(id)
	writer(data)

	unreliable = bufferWriter.export()
end

function clientProcess.invoke(id: number, requestWriter: (value: any) -> (), data: {[string]: any}): any
	local func = create()
	func = load(func)

	alloc(1)
	u8(id)
	requestWriter(data)

	func = bufferWriter.export()

	local result = {
		ready = false,
		response = {},
		data = func,
		id = id
	}

	table.insert(funcs, result)

	local waitingForResponse = coroutine.running()

	task.spawn(function()
		while true do
			if (result.ready) then
				coroutine.resume(waitingForResponse)
				break
			end

			task.wait()
		end
	end)

	coroutine.yield()
		
	local decodedData = read(result.response.dumpBuffer, result.response.reference, nil, "query")

	return decodedData
end

function clientProcess.start()
	local reliableRemote = ReplicatedStorage:WaitForChild("ByteNetReliable")
	reliableRemote.OnClientEvent:Connect(onClientEvent)

	local unreliableRemote = ReplicatedStorage:WaitForChild("ByteNetUnreliable")
	unreliableRemote.OnClientEvent:Connect(onClientEvent)

	local remoteFunction: RemoteFunction = ReplicatedStorage:WaitForChild("ByteNetQuery")

	RunService.Heartbeat:Connect(function()
		-- Again, checking if there's anything in the channel before we send it.
		if reliable.cursor > 0 then
			local b, r = dump(reliable)
			reliableRemote:FireServer(b, r)

			-- effectively clears the channel
			reliable.cursor = 0
			table.clear(reliable.references)
		end

		if unreliable.cursor > 0 then
			local b, r = dump(unreliable)
			unreliableRemote:FireServer(b, r)

			unreliable.cursor = 0
			table.clear(unreliable.references)
		end

		for i=#funcs,1,-1 do
			task.spawn(function()
				local func = funcs[i]
				table.remove(funcs, i)

				if (func.data.cursor > 0) then
					local dumpBuffer, reference = dump(func.data)
					local ResultDumpBuffer, ResultReference = remoteFunction:InvokeServer(dumpBuffer, reference, func.id)

					func.ready = true
					func.response = {
						dumpBuffer = ResultDumpBuffer,
						reference = ResultReference
					}

					func.data.cursor = 0
					table.clear(func.data.references)
				end
			end)
		end
	end)
end

return clientProcess