--[[
re = RemoteEvent,
be = BindableEvent, 
rf = RemoteFunction, 
bf = BindableFunction, 
cb = Callback, 
]]

local Registry = {}
Registry.__index = Registry

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

function Registry.new()
    local self = setmetatable({}, Registry)
    self._store = {
        re = {},
        be = {},
        rf = {},
        bf = {}
    }
    self._log = {}
    self._conn = {
        re = {},
        be = {},
        rf = {},
        bf = {}
    }
    self._parent = Instance.new("Folder")
    self._parent.Name = "RegistryStore"
    self._parent.Parent = ReplicatedStorage
    return self
end

function Registry:re(name, cb)
    if typeof(name) ~= "string" then error("name must be string") end
    if cb and typeof(cb) ~= "function" then error("cb must be function") end
    if not self._store.re[name] then
        local e = Instance.new("RemoteEvent")
        e.Name = name
        e.Parent = self._parent
        self._store.re[name] = e
        self._log[name] = {type="re", time=os.time()}
        if cb then
            if RunService:IsServer() then
                self._conn.re[name] = e.OnServerEvent:Connect(cb)
            elseif RunService:IsClient() then
                self._conn.re[name] = e.OnClientEvent:Connect(cb)
            end
        end
    end
    return self._store.re[name]
end

function Registry:be(name, cb)
    if typeof(name) ~= "string" then error("name must be string") end
    if cb and typeof(cb) ~= "function" then error("cb must be function") end
    if not self._store.be[name] then
        local e = Instance.new("BindableEvent")
        e.Name = name
        self._store.be[name] = e
        self._log[name] = {type="be", time=os.time()}
        if cb then
            self._conn.be[name] = e.Event:Connect(cb)
        end
    end
    return self._store.be[name]
end

function Registry:rf(name, cb)
    if typeof(name) ~= "string" then error("name must be string") end
    if cb and typeof(cb) ~= "function" then error("cb must be function") end
    if not self._store.rf[name] then
        local f = Instance.new("RemoteFunction")
        f.Name = name
        f.Parent = self._parent
        self._store.rf[name] = f
        self._log[name] = {type="rf", time=os.time()}
        if cb then
            if RunService:IsServer() then
                f.OnServerInvoke = cb
            elseif RunService:IsClient() then
                f.OnClientInvoke = cb
            end
            self._conn.rf[name] = true
        end
    end
    return self._store.rf[name]
end

function Registry:bf(name, cb)
    if typeof(name) ~= "string" then error("name must be string") end
    if cb and typeof(cb) ~= "function" then error("cb must be function") end
    if not self._store.bf[name] then
        local f = Instance.new("BindableFunction")
        f.Name = name
        self._store.bf[name] = f
        self._log[name] = {type="bf", time=os.time()}
        if cb then
            f.OnInvoke = cb
            self._conn.bf[name] = true
        end
    end
    return self._store.bf[name]
end

function Registry:has(name)
    return self._store.re[name] or self._store.be[name] or self._store.rf[name] or self._store.bf[name] or false
end

function Registry:meta(name)
    return self._log[name] or false
end

function Registry:wipe(name)
    if self._store.re[name] then
        if self._conn.re[name] then self._conn.re[name]:Disconnect() end
        self._store.re[name]:Destroy()
        self._store.re[name] = nil
        self._conn.re[name] = nil
    elseif self._store.be[name] then
        if self._conn.be[name] then self._conn.be[name]:Disconnect() end
        self._store.be[name]:Destroy()
        self._store.be[name] = nil
        self._conn.be[name] = nil
    elseif self._store.rf[name] then
        self._store.rf[name]:Destroy()
        self._store.rf[name] = nil
        self._conn.rf[name] = nil
    elseif self._store.bf[name] then
        self._store.bf[name]:Destroy()
        self._store.bf[name] = nil
        self._conn.bf[name] = nil
    end
    self._log[name] = nil
end

function Registry:destroy()
    for _, c in pairs(self._conn.re) do if c then c:Disconnect() end end
    for _, c in pairs(self._conn.be) do if c then c:Disconnect() end end
    for _, e in pairs(self._store.re) do e:Destroy() end
    for _, e in pairs(self._store.be) do e:Destroy() end
    for _, f in pairs(self._store.rf) do f:Destroy() end
    for _, f in pairs(self._store.bf) do f:Destroy() end
    self._store = nil
    self._log = nil
    self._conn = nil
    self._parent:Destroy()
    setmetatable(self, nil)
end

return Registry
