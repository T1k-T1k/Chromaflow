local Noclip = {}

local noclipping = false
local originalCanCollide = {}

local function setCharacterCollision(enabled)
    local character = shared.LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            if enabled then
                -- Restore original collision
                if originalCanCollide[part] ~= nil then
                    part.CanCollide = originalCanCollide[part]
                end
            else
                -- Store original collision and disable
                if originalCanCollide[part] == nil then
                    originalCanCollide[part] = part.CanCollide
                end
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end
end

function Noclip:Enable()
    if noclipping then return end
    
    local character = shared.LocalPlayer.Character
    if not character then
        shared.Notify:Error("No character found!")
        return
    end
    
    noclipping = true
    setCharacterCollision(false)
    
    -- Create noclip update loop
    shared.Connections = shared.Connections or {}
    shared.Connections.NoclipUpdate = shared.RunService.Stepped:Connect(function()
        if noclipping then
            setCharacterCollision(false)
        end
    end)
end

function Noclip:Disable()
    if not noclipping then return end
    
    noclipping = false
    
    -- Disconnect update loop
    if shared.Connections and shared.Connections.NoclipUpdate then
        shared.Connections.NoclipUpdate:Disconnect()
        shared.Connections.NoclipUpdate = nil
    end
    
    -- Restore collision
    setCharacterCollision(true)
    originalCanCollide = {}
end

function Noclip:IsEnabled()
    return noclipping
end

-- Handle character respawn
shared.LocalPlayer.CharacterAdded:Connect(function()
    originalCanCollide = {}
    if noclipping then
        wait(0.1) -- Small delay to ensure character is fully loaded
        setCharacterCollision(false)
    end
end)

return Noclip