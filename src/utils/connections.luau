local Connections = {}

-- Table to store all connections
local connectionStorage = {}

function Connections:Connect(name, signal, callback)
    -- Disconnect existing connection with the same name
    if connectionStorage[name] then
        connectionStorage[name]:Disconnect()
    end
    
    -- Create new connection
    connectionStorage[name] = signal:Connect(callback)
    return connectionStorage[name]
end

function Connections:Disconnect(name)
    if connectionStorage[name] then
        connectionStorage[name]:Disconnect()
        connectionStorage[name] = nil
        return true
    end
    return false
end

function Connections:DisconnectAll()
    for name, connection in pairs(connectionStorage) do
        connection:Disconnect()
        connectionStorage[name] = nil
    end
end

function Connections:GetConnection(name)
    return connectionStorage[name]
end

function Connections:IsConnected(name)
    return connectionStorage[name] ~= nil and connectionStorage[name].Connected
end

-- Cleanup on script unload
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == shared.LocalPlayer then
        Connections:DisconnectAll()
    end
end)

return Connections