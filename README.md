# Registry Module

# Contents

1. [Module Overview](#module-overview)
   - Purpose
   - Key Features
   - Dependencies
   - Usage Context

2. [Module Structure](#module-structure)

3. [Methods](#methods)
   - [Registry.new()](#registrynew)
   - [Registry:RemoteEvent(name, Callback)](#registryremoteeventname-callback)
   - [Registry:BindableEvent(name, Callback)](#registrybindableeventname-callback)
   - [Registry:RemoteFunction(name, Callback)](#registryremotefunctionname-callback)
   - [Registry:BindableFunction(name, Callback)](#registrybindablefunctionname-callback)
   - [Registry:has(name)](#registryhasname)
   - [Registry:meta(name)](#registrymetaname)
   - [Registry:wipe(name)](#registrywipename)
   - [Registry:destroy()](#registrydestroy)

4. [Usage Example](#usage-example)

5. [Notes](#notes)
   - Context Awareness
   - Storage


---

## Module Overview

- **Purpose**: Centralizes management of Roblox event and function instances (`RemoteEvent`, `BindableEvent`, `RemoteFunction`, `BindableFunction`) with support for server and client contexts.
- **Key Features**:
  - Dynamic instance creation and storage.
  - Context-aware callback attachment (e.g., `OnServerEvent`/`OnClientEvent`, `OnServerInvoke`/`OnClientInvoke`).
  - Metadata tracking (type, creation time).
  - Methods for querying, removing, and cleaning up instances.
  - Input validation and memory leak prevention.
- **Dependencies**: `ReplicatedStorage`, `RunService`
- **Usage Context**: Server scripts, client scripts, or modules requiring networked or local event/function management.

---

## Module Structure

The module returns a `Registry` table with a metatable for instance management. Each `Registry` instance maintains:
- A `_store` table for instances (`RemoteEvent`, `BindableEvent`, `RemoteFunction`, `BindableFunction`).
- A `_log` table for metadata (type, creation time).
- A `_connections` table for tracking event connections and function bindings.
- A `_parent` `Folder` in `ReplicatedStorage` to store networked instances.

---

## Methods

### `Registry.new()`
Creates a new `Registry` instance.

- **Returns**: `Registry` (new instance).
- **Behavior**:
  - Initializes `_store`, `_log`, and `_connections` tables.
  - Creates a `Folder` named `RegistryStore` in `ReplicatedStorage` to parent networked instances.
- **Example**:
  ```lua
  local Registry = require(path.to.Registry)
  local registry = Registry.new()
  ```

---

### `Registry:RemoteEvent(name, Callback)`
Creates or retrieves a `RemoteEvent` instance.

- **Parameters**:
  - `name` (string): Unique name for the `RemoteEvent`.
  - `Callback` (function, optional): Callback function to handle events.
- **Returns**: `RemoteEvent` instance.
- **Behavior**:
  - Validates `name` (must be a string) and `Callback` (must be a function if provided).
  - Creates a new `RemoteEvent` if none exists for `name`, parenting it to `_parent`.
  - Attaches `Callback` to `OnServerEvent` (server) or `OnClientEvent` (client) based on `RunService` context.
  - Logs metadata (`type="RemoteEvent"`, creation time).
- **Errors**:
  - "name must be string" if `name` is not a string.
  - "Callback must be function" if `Callback` is provided and not a function.
- **Example**:
  ```lua
  local event = registry:RemoteEvent("PlayerAction", function(player, action)
      print(player.Name, "performed", action)
  end)
  ```

---

### `Registry:BindableEvent(name, Callback)`
Creates or retrieves a `BindableEvent` instance.

- **Parameters**:
  - `name` (string): Unique name for the `BindableEvent`.
  - `Callback` (function, optional): Callback function to handle events.
- **Returns**: `BindableEvent` instance.
- **Behavior**:
  - Validates `name` (must be a string) and `Callback` (must be a function if provided).
  - Creates a new `BindableEvent` if none exists for `name`.
  - Attaches `Callback` to the `Event` signal if provided.
  - Logs metadata (`type="BindableEvent"`, creation time).
- **Errors**:
  - "name must be string" if `name` is not a string.
  - "Callback must be function" if `Callback` is provided and not a function.
- **Example**:
  ```lua
  local event = registry:BindableEvent("LocalSignal", function(data)
      print("Received:", data)
  end)
  ```

---

### `Registry:RemoteFunction(name, Callback)`
Creates or retrieves a `RemoteFunction` instance.

- **Parameters**:
  - `name` (string): Unique name for the `RemoteFunction`.
  - `Callback` (function, optional): Callback function to handle invocations.
- **Returns**: `RemoteFunction` instance.
- **Behavior**:
  - Validates `name` (must be a string) and `Callback` (must be a function if provided).
  - Creates a new `RemoteFunction` if none exists for `name`, parenting it to `_parent`.
  - Sets `Callback` as `OnServerInvoke` (server) or `OnClientInvoke` (client) based on `RunService` context.
  - Logs metadata (`type="RemoteFunction"`, creation time).
- **Errors**:
  - "name must be string" if `name` is not a string.
  - "Callback must be function" if `Callback` is provided and not a function.
- **Example**:
  ```lua
  local func = registry:RemoteFunction("GetData", function(player, key)
      return { key = key, value = "example" }
  end)
  ```

---

### `Registry:BindableFunction(name, Callback)`
Creates or retrieves a `BindableFunction` instance.

- **Parameters**:
  - `name` (string): Unique name for the `BindableFunction`.
  - `Callback` (function, optional): Callback function to handle invocations.
- **Returns**: `BindableFunction` instance.
- **Behavior**:
  - Validates `name` (must be a string) and `Callback` (must be a function if provided).
  - Creates a new `BindableFunction` if none exists for `name`.
  - Sets `Callback` as `OnInvoke` if provided.
  - Logs metadata (`type="BindableFunction"`, creation time).
- **Errors**:
  - "name must be string" if `name` is not a string.
  - "Callback must be function" if `Callback` is provided and not a function.
- **Example**:
  ```lua
  local func = registry:BindableFunction("Compute", function(input)
      return input * 2
  end)
  ```

---

### `Registry:has(name)`
Checks if an instance with the given name exists.

- **Parameters**:
  - `name` (string): Name of the instance to check.
- **Returns**: `boolean` (true if an instance exists, false otherwise).
- **Behavior**:
  - Checks `_store` for `RemoteEvent`, `BindableEvent`, `RemoteFunction`, or `BindableFunction` with the given `name`.
- **Example**:
  ```lua
  if registry:has("PlayerAction") then
      print("PlayerAction exists")
  end
  ```

---

### `Registry:meta(name)`
Retrieves metadata for an instance.

- **Parameters**:
  - `name` (string): Name of the instance.
- **Returns**: `table` (metadata with `type` and `time`) or `false` if no instance exists.
- **Behavior**:
  - Returns the `_log` entry for `name`, containing the instance type and creation time.
- **Example**:
  ```lua
  local meta = registry:meta("PlayerAction")
  if meta then
      print("Type:", meta.type, "Created:", meta.time)
  end
  ```

---

### `Registry:wipe(name)`
Removes a specific instance and its connections.

- **Parameters**:
  - `name` (string): Name of the instance to remove.
- **Behavior**:
  - Disconnects any associated connections (`RemoteEvent`, `BindableEvent`).
  - Destroys the instance (`RemoteEvent`, `BindableEvent`, `RemoteFunction`, `BindableFunction`).
  - Clears `_store`, `_connections`, and `_log` entries for `name`.
- **Example**:
  ```lua
  registry:wipe("PlayerAction")
  ```

---

### `Registry:destroy()`
Cleans up all managed resources.

- **Behavior**:
  - Disconnects all `RemoteEvent` and `BindableEvent` connections.
  - Destroys all instances in `_store` (`RemoteEvent`, `BindableEvent`, `RemoteFunction`, `BindableFunction`).
  - Destroys the `_parent` `Folder`.
  - Clears `_store`, `_log`, `_connections`, and removes the metatable.
- **Example**:
  ```lua
  registry:destroy()
  ```

---

## Usage Example

```lua
local Registry = require(path.to.Registry)
local registry = Registry.new()

-- Create a RemoteEvent (server-side)
registry:RemoteEvent("PlayerJump", function(player)
    print(player.Name, "jumped")
end)

-- Create a BindableEvent
local event = registry:BindableEvent("GameStart", function()
    print("Game started")
end)
event:Fire()

-- Create a RemoteFunction (client-side)
registry:RemoteFunction("GetScore", function(player)
    return 100
end)

-- Check if an instance exists
print(registry:has("PlayerJump")) -- true

-- Get metadata
print(registry:meta("PlayerJump").type) -- RemoteEvent

-- Remove an instance
registry:wipe("PlayerJump")

task.wait(120)

-- Clean up everything
registry:destroy()
```

---

## Notes

- **Context Awareness**: The module uses `RunService:IsServer()` and `RunService:IsClient()` to ensure callbacks are correctly bound for `RemoteEvent` and `RemoteFunction` instances.

- **Storage**: Networked instances (`RemoteEvent`, `RemoteFunction`) are parented to `ReplicatedStorage` for accessibility; `BindableEvent` and `BindableFunction` are stored locally.

---

