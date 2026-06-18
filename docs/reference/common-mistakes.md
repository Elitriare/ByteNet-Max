# Common mistakes

## The client cannot initialize a namespace

**Cause:** The server has not required the shared namespace module, or the client is using a different definition.

**Fix:** Put the definition in `ReplicatedStorage` and require the same ModuleScript during both server and client startup.

## `send` errors on the server

`send` is client-only. From the server, use `sendTo`, `sendToList`, `sendToAll`, or `sendToAllExcept`.

## `sendTo` errors on the client

Server targeting methods are server-only. A client can only send a packet to the server with `send`.

## Arguments to `sendTo` are reversed

Data comes first; the player comes second:

```lua
Packet.sendTo(Data, Player)
```

## A query never returns useful data

Confirm that:

1. The server registered a listener.
2. The listener returns a value.
3. The return value matches the declared `response` type.
4. The handler completes promptly.

Use one active server handler per query.

## Values wrap or lose precision

The schema is too narrow. Check numeric ranges and remember that `Color3` uses 8-bit channels while vectors and CFrames use float32 components.

## `disconnectAll` removed another system's listener

`disconnectAll` removes every listener for that packet or query in the current runtime. Keep and call the specific disconnect function returned by `listen` instead.

## The server accepts impossible actions

Data types validate representation, not game rules. Validate all client actions against server-owned state. See [Security and limits](../guides/security.md).
