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

-- Shared with: src/process/server.luau (Infeasible to split this into another file)
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
local func: types.channelData = create()

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

function clientProcess.invoke(id: number, writer: (value: any) -> (), data: {[string]: any}): any
	if waitingForResponse then 
		repeat task.wait() until not waitingForResponse
	end

	func = load(func)

	alloc(1)
	u8(id)
	writer(data)

	func = bufferWriter.export()

	local remoteFunction: RemoteFunction = ReplicatedStorage:WaitForChild("ByteNetQuery")
	local dumpBuffer, reference = dump(func)

	waitingForResponse = true
	local response = remoteFunction:InvokeServer(dumpBuffer, reference)

	if response then waitingForResponse = false end

	return response
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
		
		if func.cursor > 0 then
			local dumpBuffer, reference = dump(func)
			local Result = remoteFunction:InvokeServer(dumpBuffer, reference)
						
			func.cursor = 0
			table.clear(func.references)
		end
	end)
end

return clientProcess