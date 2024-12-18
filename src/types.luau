export type namespaceData = {
	packets: {
		[string]: any,
	},
	queries: {
		[string]: any,
	},
	structs: {
		[number]: {
			[string]: any,
		},
	},
}

-- Externally used for defining packets
export type packetProps<T> = {
	value: T,
	reliabilityType: ("reliable" | "unreliable")?,
	callbackBehavior: {
		spawnThread: boolean,
		allowMultiple: boolean,
	}?,
}

-- Externally used for defining queries
export type queryProperties<RequestType, ResponseType> = {
	request: RequestType,
	response: ResponseType,
	callbackBehavior: {
		spawnThread: boolean,
		allowMultiple: boolean
	}?
}

-- Used internally for packet & query request/response queues 
export type channelData = {
	cursor: number,
	size: number,
	references: { unknown },
	buff: buffer,
}

export type remoteFunctionChannel = {
	ready: boolean, 
	response: any?, 
	data: channelData,
	id: number
}

-- Used internally for serializing and deserializing all data types
export type dataTypeInterface<T> = {
	write: (value: T) -> (),
	read: (b: buffer, cursor: number, references: { [number]: unknown }?) -> (T, number),
}

-- Somewhat public facing: used as return result in definePacket
type Packet<T> = {
	sendToAll: (data: T) -> (),
	sendTo: (data: T, target: Player) -> (),
	sendToList: (data: T, targets: { Player }) -> (),

	wait: () -> T,
	send: (data: T, target: Player?) -> (),
	listen: (callback: (data: T, player: Player?) -> ()) -> (),
	listenOnce: (callback: (data: T, player: Player?) -> ()) -> (),
	disconnectAll: () -> ()
}

-- used as return result in defineQuery
type Query<RequestType, ResponseType> = {
	invoke: (request: RequestType, target: Player?) -> ResponseType,
	listen: (callback: (request: RequestType, player: Player?) -> ResponseType) -> (),
	listenOnce: (callback: (request: RequestType, player: Player?) -> ResponseType) -> (),
	disconnectAll: () -> ()
}

-- Library type
export type ByteNet = {
	definePacket: <T>(props: packetProps<T>) -> Packet<T>,
	defineQuery: <RequestType, ResponseType>(properties: queryProperties<RequestType, ResponseType>) -> Query<RequestType, ResponseType>,
	defineNamespace: <T>(name: string, namespace: () -> namespaceData & T) -> T,

	struct: <T>(format: T) -> T,
	bool: boolean,
	array: <T>(value: T) -> { [number]: T },
	optional: <T>(value: T) -> T?,
	inst: Instance,
	nothing: nil,
	unknown: unknown,
	uint8: number,
	uint16: number,
	uint32: number,
	int8: number,
	int16: number,
	int32: number,
	float32: number,
	float64: number,
	string: string,
	vec3: Vector3,
	vec2: Vector2,
	buff: buffer,
	color3: Color3,
	cframe: CFrame,
	map: <K, V>(key: K, value: V) -> { [K]: V },

	-- TYPES
	playerIdentifier: number,
	playerName: string,
}

return nil