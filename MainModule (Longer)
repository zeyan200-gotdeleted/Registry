

local Registry = {}
Registry.__index = Registry

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

function Registry.new()
    local self = setmetatable({}, Registry)
    self._store = {
        RemoteEvent = {},
        BindableEvent = {},
        RemoteFunction = {},
        BindableFunction = {}
    }
    self._log = {}
    self._connections = {
        RemoteEvent = {},
        BindableEvent = {},
        RemoteFunction = {},
        BindableFunction = {}
    }
    self._parent = Instance.new("Folder")
    self._parent.Name = "RegistryStore"
    self._parent.Parent = ReplicatedStorage
    return self
end

function Registry:RemoteEvent(name, Callback)
    if typeof(name) ~= "string" then error("name must be string") end
    if Callback and typeof(Callback) ~= "function" then error("Callback must be function") end
    if not self._store.RemoteEvent[name] then
        local Event = Instance.new("RemoteEvent")
        Event.Name = name
        Event.Parent = self._parent
        self._store.RemoteEvent[name] = Event
        self._log[name] = {type="RemoteEvent", time=os.time()}
        if Callback then
            if RunService:IsServer() then
                self._connections.RemoteEvent[name] = Event.OnServerEvent:Connect(Callback)
            elseif RunService:IsClient() then
                self._connections.RemoteEvent[name] = Event.OnClientEvent:Connect(Callback)
            end
        end
    end
    return self._store.RemoteEvent[name]
end

function Registry:BindableEvent(name, Callback)
    if typeof(name) ~= "string" then error("name must be string") end
    if Callback and typeof(Callback) ~= "function" then error("Callback must be function") end
    if not self._store.BindableEvent[name] then
        local Event = Instance.new("BindableEvent")
        Event.Name = name
        self._store.BindableEvent[name] = Event
        self._log[name] = {type="BindableEvent", time=os.time()}
        if Callback then
            self._connections.BindableEvent[name] = Event.Event:Connect(Callback)
        end
    end
    return self._store.BindableEvent[name]
end

function Registry:RemoteFunction(name, Callback)
    if typeof(name) ~= "string" then error("name must be string") end
    if Callback and typeof(Callback) ~= "function" then error("Callback must be function") end
    if not self._store.RemoteFunction[name] then
        local Function = Instance.new("RemoteFunction")
        Function.Name = name
        Function.Parent = self._parent
        self._store.RemoteFunction[name] = Function
        self._log[name] = {type="RemoteFunction", time=os.time()}
        if Callback then
            if RunService:IsServer() then
                Function.OnServerInvoke = Callback
            elseif RunService:IsClient() then
                Function.OnClientInvoke = Callback
            end
            self._connections.RemoteFunction[name] = true
        end
    end
    return self._store.RemoteFunction[name]
end

function Registry:BindableFunction(name, Callback)
    if typeof(name) ~= "string" then error("name must be string") end
    if Callback and typeof(Callback) ~= "function" then error("Callback must be function") end
    if not self._store.BindableFunction[name] then
        local Function = Instance.new("BindableFunction")
        Function.Name = name
        self._store.BindableFunction[name] = Function
        self._log[name] = {type="BindableFunction", time=os.time()}
        if Callback then
            Function.OnInvoke = Callback
            self._connections.BindableFunction[name] = true
        end
    end
    return self._store.BindableFunction[name]
end

function Registry:has(name)
    return self._store.RemoteEvent[name] or self._store.BindableEvent[name] or self._store.RemoteFunction[name] or self._store.BindableFunction[name] or false
end

function Registry:meta(name)
    return self._log[name] or false
end

function Registry:wipe(name)
    if self._store.RemoteEvent[name] then
        if self._connections.RemoteEvent[name] then self._connections.RemoteEvent[name]:Disconnect() end
        self._store.RemoteEvent[name]:Destroy()
        self._store.RemoteEvent[name] = nil
        self._connections.RemoteEvent[name] = nil
    elseif self._store.BindableEvent[name] then
        if self._connections.BindableEvent[name] then self._connections.BindableEvent[name]:Disconnect() end
        self._store.BindableEvent[name]:Destroy()
        self._store.BindableEvent[name] = nil
        self._connections.BindableEvent[name] = nil
    elseif self._store.RemoteFunction[name] then
        self._store.RemoteFunction[name]:Destroy()
        self._store.RemoteFunction[name] = nil
        self._connections.RemoteFunction[name] = nil
    elseif self._store.BindableFunction[name] then
        self._store.BindableFunction[name]:Destroy()
        self._store.BindableFunction[name] = nil
        self._connections.BindableFunction[name] = nil
    end
    self._log[name] = nil
end

function Registry:destroy()
    for _, Connection in pairs(self._connections.RemoteEvent) do if Connection then Connection:Disconnect() end end
    for _, Connection in pairs(self._connections.BindableEvent) do if Connection then Connection:Disconnect() end end
    for _, Event in pairs(self._store.RemoteEvent) do Event:Destroy() end
    for _, Event in pairs(self._store.BindableEvent) do Event:Destroy() end
    for _, Function in pairs(self._store.RemoteFunction) do Function:Destroy() end
    for _, Function in pairs(self._store.BindableFunction) do Function:Destroy() end
    self._store = nil
    self._log = nil
    self._connections = nil
    self._parent:Destroy()
    setmetatable(self, nil)
end

return Registry
