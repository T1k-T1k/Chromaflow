local UICreator = require("ui/creator")
local Services = shared

-- Create Universal Tab
local UniversalTab = UICreator:CreateTab(shared.Window, "Universal")

-- Movement Section
local MovementSection = UICreator:CreateSection(UniversalTab, "Movement")

-- Fly Toggle
local FlyEnabled = false
UICreator:CreateToggle(
    MovementSection,
    "Fly",
    false,
    function(value)
        FlyEnabled = value
        
        if FlyEnabled then
            shared.Fly:Enable()
            print("[Chromaflow] Fly enabled")
        else
            shared.Fly:Disable()
            print("[Chromaflow] Fly disabled")
        end
    end
)

-- Noclip Toggle
local NoclipEnabled = false
UICreator:CreateToggle(
    MovementSection,
    "Noclip",
    false,
    function(value)
        NoclipEnabled = value
        
        if NoclipEnabled then
            shared.Noclip:Enable()
            print("[Chromaflow] Noclip enabled")
        else
            shared.Noclip:Disable()
            print("[Chromaflow] Noclip disabled")
        end
    end
)

-- Speed Slider
UICreator:CreateSlider(
    MovementSection,
    "Walk Speed",
    16,
    100,
    16,
    1,
    function(value)
        local character = Services.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
        print("[Chromaflow] Walk speed set to: " .. tostring(value))
    end
)

-- Jump Power Slider
UICreator:CreateSlider(
    MovementSection,
    "Jump Power",
    50,
    200,
    50,
    5,
    function(value)
        local character = Services.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = value
        end
        print("[Chromaflow] Jump power set to: " .. tostring(value))
    end
)

-- Player Section
local PlayerSection = UICreator:CreateSection(UniversalTab, "Player")

-- God Mode Toggle
local GodModeEnabled = false
local HealthConnection = nil

UICreator:CreateToggle(
    PlayerSection,
    "God Mode",
    false,
    function(value)
        GodModeEnabled = value
        
        if GodModeEnabled then
            local character = Services.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.MaxHealth = math.huge
                character.Humanoid.Health = math.huge
                
                HealthConnection = character.Humanoid.HealthChanged:Connect(function()
                    if GodModeEnabled then
                        character.Humanoid.Health = math.huge
                    end
                end)
            end
            print("[Chromaflow] God Mode enabled")
        else
            if HealthConnection then
                HealthConnection:Disconnect()
                HealthConnection = nil
            end
            
            local character = Services.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.MaxHealth = 100
                character.Humanoid.Health = 100
            end
            print("[Chromaflow] God Mode disabled")
        end
    end
)

-- Infinite Stamina Toggle (if applicable)
UICreator:CreateToggle(
    PlayerSection,
    "Infinite Stamina",
    false,
    function(value)
        if value then
            print("[Chromaflow] Infinite Stamina enabled")
            -- Логика для бесконечной выносливости (зависит от игры)
        else
            print("[Chromaflow] Infinite Stamina disabled")
        end
    end
)

-- Visual Section
local VisualSection = UICreator:CreateSection(UniversalTab, "Visual")

-- Fullbright Toggle
local FullbrightEnabled = false
UICreator:CreateToggle(
    VisualSection,
    "Fullbright",
    false,
    function(value)
        FullbrightEnabled = value
        
        if FullbrightEnabled then
            Services.Lighting.Brightness = 2
            Services.Lighting.ClockTime = 14
            Services.Lighting.FogEnd = 100000
            Services.Lighting.GlobalShadows = false
            Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            print("[Chromaflow] Fullbright enabled")
        else
            -- Reset to default lighting (approximate values)
            Services.Lighting.Brightness = 1
            Services.Lighting.ClockTime = 12
            Services.Lighting.FogEnd = 100000
            Services.Lighting.GlobalShadows = true
            Services.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
            print("[Chromaflow] Fullbright disabled")
        end
    end
)

-- ESP Toggle (placeholder)
UICreator:CreateToggle(
    VisualSection,
    "ESP",
    false,
    function(value)
        if value then
            print("[Chromaflow] ESP enabled")
            -- ESP logic would go here
        else
            print("[Chromaflow] ESP disabled")
        end
    end
)

-- Misc Section
local MiscSection = UICreator:CreateSection(UniversalTab, "Miscellaneous")

-- Remove Chat Limit Toggle
UICreator:CreateToggle(
    MiscSection,
    "Remove Chat Limit",
    false,
    function(value)
        if value then
            print("[Chromaflow] Chat limit removed")
            -- Logic to remove chat character limit
        else
            print("[Chromaflow] Chat limit restored")
        end
    end
)

-- Auto Respawn Toggle
local AutoRespawnEnabled = false
local RespawnConnection = nil

UICreator:CreateToggle(
    MiscSection,
    "Auto Respawn",
    false,
    function(value)
        AutoRespawnEnabled = value
        
        if AutoRespawnEnabled then
            RespawnConnection = Services.LocalPlayer.CharacterRemoving:Connect(function()
                if AutoRespawnEnabled then
                    wait(1)
                    Services.LocalPlayer:LoadCharacter()
                end
            end)
            print("[Chromaflow] Auto Respawn enabled")
        else
            if RespawnConnection then
                RespawnConnection:Disconnect()
                RespawnConnection = nil
            end
            print("[Chromaflow] Auto Respawn disabled")
        end
    end
)

-- Update stats when character spawns
Services.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Apply current settings to new character
    if shared.Options["Walk Speed"] then
        humanoid.WalkSpeed = shared.Options["Walk Speed"].Value
    end
    
    if shared.Options["Jump Power"] then
        humanoid.JumpPower = shared.Options["Jump Power"].Value
    end
    
    if GodModeEnabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        if HealthConnection then
            HealthConnection:Disconnect()
        end
        
        HealthConnection = humanoid.HealthChanged:Connect(function()
            if GodModeEnabled then
                humanoid.Health = math.huge
            end
        end)
    end
end)

print("[Chromaflow] Universal script loaded successfully!")