--!native
local packetIDs = require(script.Parent.Parent.namespaces.packetIDs)
local queryIDs = require(script.Parent.Parent.namespaces.queryIDs)
local readRefs = require(script.Parent.readRefs)

local packetRef = packetIDs.ref()
local queryRef = queryIDs.ref()
local freeThread: thread?

local function functionPasser(callback, ...)
	local aquiredThread = freeThread
	freeThread = nil
	callback(...)
	freeThread = aquiredThread
end

local function yielder()
	while true do
		functionPasser(coroutine.yield())
	end
end

local function runListener(callback, ...)
	if freeThread == nil then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread :: thread)
	end

	task.spawn(freeThread :: thread, callback, ...)
end

local function runQueryListener(callback, ...)
	local result 
	if freeThread == nil then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread :: thread)
	end

	task.spawn(freeThread :: thread, function(...)
		result = callback(...)
	end, ...)
		
	return result
end

return function(incomingBuffer: buffer, references: { [number]: unknown }?, player: Player?, readType: string?)
	local length = buffer.len(incomingBuffer)
	local readCursor = 0
	readType = readType or "packet"

	readRefs.set(references)

	while readCursor < length do
		local readablePacketOrQuery
		
		if readType == "packet" then
			readablePacketOrQuery = packetRef[buffer.readu8(incomingBuffer, readCursor)]
		elseif readType == "query" then
			readablePacketOrQuery = queryRef[buffer.readu8(incomingBuffer, readCursor)]
		else
			error("readType not valid.")
		end
				
		if not readablePacketOrQuery then
			error("No readable entity found for ID: " .. buffer.readu8(incomingBuffer, readCursor) .. " for type: " .. readType)
		end
		
		readCursor += 1

		local value, valueLength = readablePacketOrQuery.reader(incomingBuffer, readCursor)

		readCursor += valueLength

		if readType == "packet" then
			for _, listener in readablePacketOrQuery.getListeners() do
				runListener(listener, value, player)
			end
		elseif readType == "query" then
			for _, listener in readablePacketOrQuery.getListeners() do
				local response = runQueryListener(listener, value, player)
				
				return response
			end	
		end
	end
end
