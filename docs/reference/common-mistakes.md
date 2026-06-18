# Common mistakes

## The client cannot initialize a namespace

**Cause:** The server has not required the shared namespace module, or the client is using a different definition.

**Fix:** Put the definition in `ReplicatedStorage`, initialize it on the server first, and require the exact same ModuleScript during client startup. Follow [Required initialization](../getting-started/initialization.md).

## A packet/query ID is invalid or unreadable

This usually indicates one of three problems:

1. The namespace was not initialized on both server and client.
2. The two runtimes loaded different definitions or package versions.
3. The payload does not match the declared schema.

Verify shared initialization before debugging individual sends.

## A struct arrives incorrectly

`struct` values are dictionaries, not positional arrays. Match every declared field name:

```lua
-- Schema
ByteNetMax.struct({ Message = ByteNetMax.string })

-- Correct
Packet.send({ Message = "Hello" })

-- Incorrect
Packet.send({ "Hello" })
```

## Packets or queries are missing from the namespace

Return a `packets` table when defining packets and a `queries` table when defining queries. Return both when using both.

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

## Can I send functions?

No. Roblox remotes cannot transmit functions. Send data that identifies the action, then map that identifier to trusted code on the receiving side.

## `disconnectAll` removed another system's listener

`disconnectAll` removes every listener for that packet or query in the current runtime. Keep and call the specific disconnect function returned by `listen` instead.

## The server accepts impossible actions

Data types validate representation, not game rules. Validate all client actions against server-owned state. See [Security and limits](../guides/security.md).
