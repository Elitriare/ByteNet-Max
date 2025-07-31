--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local alloc = bufferWriter.alloc
local u8 = bufferWriter.u8
local load = bufferWriter.load

local MAX_BUFFER_SIZE = math.floor(script.Parent.Parent:GetAttribute("MAX_BUFFER_SIZE") or 4096)
local rateLimit = {
	bytesPerSec = MAX_BUFFER_SIZE,
	refillRate = MAX_BUFFER_SIZE,
}

-- All channelData is set to nil upon being sent which is why these are all optionals
local perPlayerReliable: { [Player]: types.channelData } = {}
local perPlayerUnreliable: { [Player]: types.channelData } = {}
local playerRateLimits: {} = {}

-- Shared with: src/process/client.luau, src/process/read.luau (Infeasible to split this into another file)
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

local globalReliable: types.channelData = create()
local globalUnreliable: types.channelData = create()

-- Rate Limit
local function checkPlayerAllowedToSend(player: Player, size: number)
	local now = os.clock()
	local elapsed = now - playerRateLimits[player].lastTime
	
	playerRateLimits[player].currentBytes = math.min(
		playerRateLimits[player].currentBytes + (elapsed * rateLimit.refillRate),
		rateLimit.bytesPerSec
	)

	playerRateLimits[player].lastTime = now

	if playerRateLimits[player].currentBytes >= size then
		playerRateLimits[player].currentBytes -= size
		return true
	else
		return false
	end
end	

local function verifyBuffer(player: Player, data)
	if not (typeof(data) == "buffer") then
		warn("Data is not a buffer.")
		return false
	end

	local dataSize = buffer.len(data)

	if dataSize > MAX_BUFFER_SIZE then
		warn("Buffer is too large. Size limit exceeded: " .. tostring(MAX_BUFFER_SIZE) .. " bytes.")
		return false
	end 

	if not checkPlayerAllowedToSend(player, dataSize) then
		warn("Rate limit exceeded: " .. tostring(rateLimit.bytesPerSec) .. " bytes per second.")
		return false
	end
	
	return true
end

-- TODO handle invalid data better
local function onServerEvent(player: Player, data, references)
	if not verifyBuffer(player, data) then
		return
	end

	read(data, references, player)
end

local function onServerInvoke(player: Player, data, references, id: number)
	if not verifyBuffer(player, data) then
		return
	end
	
	local dumpBuffer, reference = read(data, references, player, "query", id)
		
	return dumpBuffer, reference
end

local function playerAdded(player)
	if not perPlayerReliable[player] then
		perPlayerReliable[player] = create()
	end

	if not perPlayerUnreliable[player] then
		perPlayerUnreliable[player] = create()
	end
	
	playerRateLimits[player] = {
		lastTime = os.clock(),
		currentBytes = MAX_BUFFER_SIZE -- the start limit, sorta like a bank of bytes. as player uses bytes, it deducts from this storage. but it refills at refillRate
	}
end

local function playerRemoving(player: Player)
	local reliableEventCursor = perPlayerReliable[player]
	local unreliableEventCursor = perPlayerUnreliable[player]
	local playerRateLimit = playerRateLimits[player]

	if reliableEventCursor ~= nil then
		perPlayerReliable[player] = nil
	end

	if unreliableEventCursor ~= nil then
		perPlayerUnreliable[player] = nil
	end
	
	if playerRateLimit ~= nil then
		playerRateLimits[player] = nil
	end
end

local serverProcess = {}

function serverProcess.sendAllReliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	load(globalReliable)

	alloc(1)
	u8(id)
	writer(data)

	globalReliable = bufferWriter.export()
end

function serverProcess.sendAllUnreliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	load(globalUnreliable or create())

	alloc(1)
	u8(id)
	writer(data)

	globalUnreliable = bufferWriter.export()
end

function serverProcess.sendPlayerReliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	load(perPlayerReliable[player] or create())

	alloc(1)
	u8(id)
	writer(data)

	perPlayerReliable[player] = bufferWriter.export()
end

function serverProcess.sendPlayerUnreliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	load(perPlayerUnreliable[player])

	alloc(1)
	u8(id)
	writer(data)

	perPlayerUnreliable[player] = bufferWriter.export()
end

function serverProcess.start()	
	local eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "system"
	eventsFolder.Parent = script.Parent.Parent
	
	local reliableRemote = Instance.new("RemoteEvent")
	reliableRemote.Name = "ByteNetReliable"
	reliableRemote.OnServerEvent:Connect(onServerEvent)
	reliableRemote.Parent = eventsFolder

	local unreliableRemote = Instance.new("UnreliableRemoteEvent")
	unreliableRemote.Name = "ByteNetUnreliable"
	unreliableRemote.OnServerEvent:Connect(onServerEvent)
	unreliableRemote.Parent = eventsFolder
	
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = "ByteNetQuery"
	remoteFunc.OnServerInvoke = onServerInvoke
	remoteFunc.Parent = eventsFolder

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)

	RunService.Heartbeat:Connect(function()
		-- Check if the channel has anything before trying to send it
		if globalReliable.cursor > 0 then
			local dumpBuffer, references = dump(globalReliable)
			reliableRemote:FireAllClients(dumpBuffer, references)

			globalReliable.cursor = 0
			table.clear(globalReliable.references)
		end

		if globalUnreliable.cursor > 0 then
			local b, r = dump(globalUnreliable)
			unreliableRemote:FireAllClients(b, r)

			globalUnreliable.cursor = 0
			table.clear(globalUnreliable.references)
		end

		for _, player in Players:GetPlayers() do
			local reliableEventCursor = perPlayerReliable[player]
			local unreliableEventCursor = perPlayerUnreliable[player]
			
			if reliableEventCursor ~= nil and reliableEventCursor.cursor > 0 then
				local b, r = dump(reliableEventCursor)
				reliableRemote:FireClient(player, b, r)

				reliableEventCursor.cursor = 0
				table.clear(reliableEventCursor.references)
			end

			if unreliableEventCursor ~= nil and unreliableEventCursor.cursor > 0 then
				local b, r = dump(unreliableEventCursor)
				unreliableRemote:FireClient(player, b, r)

				unreliableEventCursor.cursor = 0
				table.clear(unreliableEventCursor.references)
			end
		end
	end)
end

return serverProcess
