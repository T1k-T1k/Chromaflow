local Fly = {}

local flying = false
local bodyVelocity = nil
local bodyAngularVelocity = nil
local camera = workspace.CurrentCamera
local player = shared.LocalPlayer

local function createFlyForces()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    
    -- Remove existing forces
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
    
    -- Create new BodyVelocity
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    -- Create BodyAngularVelocity for stability
    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = rootPart
    
    return true
end

local function updateFlyMovement()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not bodyVelocity then
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local moveVector = humanoid.MoveDirection
    local cameraDirection = camera.CFrame.LookVector
    local cameraRight = camera.CFrame.RightVector
    
    local velocity = Vector3.new(0, 0, 0)
    
    -- Forward/Backward movement
    if moveVector.Magnitude > 0 then
        velocity = velocity + (cameraDirection * moveVector.Z * -1)
        velocity = velocity + (cameraRight * moveVector.X)
    end
    
    -- Up/Down movement
    local userInput = shared.UserInputService
    if userInput:IsKeyDown(Enum.KeyCode.Space) then
        velocity = velocity + Vector3.new(0, 1, 0)
    end
    if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then
        velocity = velocity + Vector3.new(0, -1, 0)
    end
    
    -- Apply velocity
    local speed = 50 -- Base fly speed
    bodyVelocity.Velocity = velocity * speed
end

function Fly:Enable()
    if flying then return end
    
    local character = player.Character
    if not character then
        shared.Notify:Error("No character found!")
        return
    end
    
    if not createFlyForces() then
        shared.Notify:Error("Failed to initialize fly!")
        return
    end
    
    flying = true
    
    -- Create fly update loop
    shared.Connections = shared.Connections or {}
    shared.Connections.FlyUpdate = shared.RunService.Heartbeat:Connect(updateFlyMovement)
    
    -- Disable character physics
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
end

function Fly:Disable()
    if not flying then return end
    
    flying = false
    
    -- Disconnect update loop
    if shared.Connections and shared.Connections.FlyUpdate then
        shared.Connections.FlyUpdate:Disconnect()
        shared.Connections.FlyUpdate = nil
    end
    
    -- Remove body forces
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyAngularVelocity then
        bodyAngularVelocity:Destroy()
        bodyAngularVelocity = nil
    end
    
    -- Re-enable character physics
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

function Fly:IsEnabled()
    return flying
end

return Fly