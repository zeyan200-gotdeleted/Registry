# Registry Module

## Contents

1. [Overview](#overview)
2. [Design Goals](#design-goals)
3. [Runtime Context](#runtime-context)
4. [Internal Structure](#internal-structure)
5. [API Reference](#api-reference)

   * [`Registry.new()`](#registrynew)
   * [`Registry:RemoteEvent(name, callback)`](#registryremoteeventname-callback)
   * [`Registry:RemoteFunction(name, callback)`](#registryremotefunctionname-callback)
   * [`Registry:BindableEvent(name, callback)`](#registrybindableeventname-callback)
   * [`Registry:BindableFunction(name, callback)`](#registrybindablefunctionname-callback)
   * [`Registry:has(name)`](#registryhasname)
   * [`Registry:meta(name)`](#registrymetaname)
   * [`Registry:wipe(name)`](#registrywipename)
   * [`Registry:destroy()`](#registrydestroy)
6. [Usage Examples](#usage-examples)
7. [Important Notes & Pitfalls](#important-notes--pitfalls)

---

## Overview

The **Registry Module** provides a unified, context-aware system for creating, storing, retrieving, and cleaning up Roblox communication primitives:

* `RemoteEvent`
* `RemoteFunction`
* `BindableEvent`
* `BindableFunction`

It ensures consistent naming, lifecycle management, and safe server/client behavior while reducing boilerplate and preventing duplicate instances.

---

## Design Goals

* Centralized instance management
* Safe server/client separation
* Automatic creation and retrieval
* Single-callback enforcement per name
* Predictable cleanup and destruction
* Metadata tracking for debugging and introspection

---

## Runtime Context

The Registry is **context-aware**:

| Context | Behavior                            |
| ------- | ----------------------------------- |
| Server  | Creates and owns Remote instances   |
| Client  | Waits for Remote instances to exist |
| Both    | Can attach appropriate callbacks    |

Context detection is handled via `RunService:IsServer()` and `RunService:IsClient()`.

---

## Internal Structure

Each Registry instance maintains:

* `_store` — Active instances by type
* `_connections` — Event connections and function bindings
* `_log` — Metadata (`type`, `creation time`)
* `_parent` — `Folder` named **RegistryStore** in `ReplicatedStorage`

### Storage Rules

| Instance Type    | Location                          |
| ---------------- | --------------------------------- |
| RemoteEvent      | `ReplicatedStorage/RegistryStore` |
| RemoteFunction   | `ReplicatedStorage/RegistryStore` |
| BindableEvent    | Local (not parented)              |
| BindableFunction | Local (not parented)              |

Bindable objects are **local to the Registry instance** and are not shared across scripts.

---

## API Reference

---

### `Registry.new()`

Creates a new Registry instance.

**Returns:** `Registry`

**Behavior:**

* Initializes internal storage and connection tracking
* Creates (server) or waits for (client) `RegistryStore` in `ReplicatedStorage`

```lua
local Registry = require(path.to.Registry)
local registry = Registry.new()
```

---

### `Registry:RemoteEvent(name, callback)`

Creates or retrieves a `RemoteEvent`.

**Parameters:**

* `name` *(string, required)*
* `callback` *(function, optional)*

**Returns:** `RemoteEvent`

**Behavior:**

* Creates the RemoteEvent on the server if missing
* Waits for the RemoteEvent on the client if missing
* Attaches exactly **one** callback per name
* Callback binds to:

  * `OnServerEvent` (server)
  * `OnClientEvent` (client)

**Important:**

* Only one callback may be bound per event name
* Additional callbacks passed later are ignored

```lua
local event = registry:RemoteEvent("PlayerAction", function(player, action)
	print(player.Name, action)
end)
```

---

### `Registry:RemoteFunction(name, callback)`

Creates or retrieves a `RemoteFunction`.

**Parameters:**

* `name` *(string, required)*
* `callback` *(function, optional)*

**Returns:** `RemoteFunction`

**Behavior:**

* Creates on server, waits on client
* Assigns exactly one invoke handler per name
* Callback binds to:

  * `OnServerInvoke` (server)
  * `OnClientInvoke` (client)

```lua
registry:RemoteFunction("GetScore", function(player)
	return 100
end)
```

---

### `Registry:BindableEvent(name, callback)`

Creates or retrieves a local `BindableEvent`.

**Parameters:**

* `name` *(string, required)*
* `callback` *(function, optional)*

**Returns:** `BindableEvent`

**Behavior:**

* Stored locally inside the Registry instance
* Not parented or shared
* One callback per name

```lua
local event = registry:BindableEvent("GameStart", function()
	print("Game started")
end)

event:Fire()
```

---

### `Registry:BindableFunction(name, callback)`

Creates or retrieves a local `BindableFunction`.

**Parameters:**

* `name` *(string, required)*
* `callback` *(function, optional)*

**Returns:** `BindableFunction`

```lua
registry:BindableFunction("Compute", function(x)
	return x * 2
end)
```

---

### `Registry:has(name)`

Checks whether an instance exists.

**Parameters:**

* `name` *(string)*

**Returns:**

* The instance if found
* `false` otherwise

```lua
local instance = registry:has("PlayerAction")
if instance then
	print("Exists:", instance.ClassName)
end
```

---

### `Registry:meta(name)`

Returns metadata for an instance.

**Returns:**

* `{ type: string, time: number }`
* `false` if not found

```lua
local meta = registry:meta("PlayerAction")
print(meta.type, meta.time)
```

---

### `Registry:wipe(name)`

Removes a specific instance.

**Behavior:**

* Disconnects callbacks
* Destroys the instance
* Clears metadata

```lua
registry:wipe("PlayerAction")
```

---

### `Registry:destroy()`

Destroys the entire Registry.

**Behavior:**

* Disconnects all callbacks
* Destroys all managed instances
* Clears internal state
* Destroys `RegistryStore` **only on the server**

```lua
registry:destroy()
```

---

## Usage Examples

### Safe RemoteEvent Pattern (Recommended)

```lua
local event
event = registry:RemoteEvent("Ping", function(player)
	event:FireClient(player, "Pong")
end)
```

### Client Invoke Example

```lua
local func = registry:RemoteFunction("Add")
print(func:InvokeServer(2, 3))
```

---

## Important Notes & Pitfalls

### ⚠️ Upvalue Capture Rule

If a callback references the instance it belongs to, **declare first, assign second**:

```lua
local event
event = registry:RemoteEvent("Example", function()
	event:FireAllClients()
end)
```

Failing to do this may result in `nil` access errors.

---

### ⚠️ Single Callback Per Name

Each Registry name supports **one callback only**.
Subsequent callbacks are ignored silently.

---

### ⚠️ Registry Instances Are Isolated

Bindable objects and metadata are **not shared** between different Registry instances.
