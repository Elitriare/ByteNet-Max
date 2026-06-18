# Queries

Queries provide typed client-to-server request/response calls.

## Define a query

Every query requires both a request and response data type:

```lua
GetLoadout = ByteNetMax.defineQuery({
	request = ByteNetMax.nothing,
	response = ByteNetMax.array(ByteNetMax.string),
})
```

## Handle it on the server

Register one server listener and return a response of the declared type:

```lua
Network.queries.GetLoadout.listen(function(_, Player)
	return LoadoutService:GetItemIds(Player)
end)
```

The callback receives `(Request, Player)`.

## Invoke it on the client

```lua
local ItemIds = Network.queries.GetLoadout.invoke(nil)
```

`invoke` yields the calling thread until it receives the response.

## Listener lifecycle

Queries expose the same listener utilities as packets:

| Method | Behavior |
| --- | --- |
| `listen(callback)` | Registers a handler and returns a disconnect function |
| `listenOnce(callback)` | Handles the next request, then disconnects |
| `wait()` | Yields for the next request |
| `disconnectAll()` | Removes all query listeners in this runtime |

## Rules for robust queries

1. Register exactly one active server handler for each query.
2. Always return a value compatible with `response`.
3. Return promptly. The current server implementation stops waiting after 10 seconds.
4. Validate the request using server-owned state.
5. Do not use queries for high-frequency updates or notifications.

!!! danger "Do not trust query arguments"
    A query is still client input. Treat `Player` as the identity and verify every requested resource, item, amount, and permission on the server.

## When a packet is better

Use a packet when the client does not need an immediate result. A packet avoids blocking the caller and communicates intent more clearly.

| Scenario | Recommended primitive |
| --- | --- |
| Fetch a profile summary | Query |
| Request a purchase and need a result | Query |
| Tell the server a button was pressed | Packet |
| Push a UI update to a client | Packet |
