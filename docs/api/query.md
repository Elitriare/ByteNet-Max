# `defineQuery`

Defines a typed client-to-server request and server-to-client response.

```lua
ByteNetMax.defineQuery({
	request = RequestDataType,
	response = ResponseDataType,
})
```

## Properties

| Property | Required | Description |
| --- | --- | --- |
| `request` | Yes | Data type used to serialize the client request |
| `response` | Yes | Data type used to serialize the server response |

## Methods

| Method | Runtime | Returns | Description |
| --- | --- | --- | --- |
| `invoke(request)` | Client | Response value | Yields until the server responds |
| `listen(callback)` | Server | Disconnect function | Adds a persistent request handler |
| `listenOnce(callback)` | Server | Disconnect function | Handles one request, then disconnects |
| `wait()` | Server | Request and player | Yields until a request arrives |
| `disconnectAll()` | Both | `nil` | Removes all listeners for this query |

The server callback receives `(Request, Player)` and must return a value compatible with `response`.

See the [Queries guide](../guides/queries.md) for lifecycle and safety guidance.
