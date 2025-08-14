local UICreator = require("ui/creator")
local Services = shared

-- Create Main Tab
local MainTab = UICreator:CreateTab(shared.Window, "Main")

-- Sniper Section
local SniperSection = UICreator:CreateSection(MainTab, "Sniper")

-- Get all players except LocalPlayer
local function GetPlayerList()
    local playerList = {}
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Target Dropdown
local TargetDropdown = UICreator:CreateDropdown(
    SniperSection, 
    "Target", 
    GetPlayerList(), 
    nil,
    function(selectedPlayer)
        print("[Chromaflow] Selected target: " .. tostring(selectedPlayer))
        -- Здесь будет логика для снайпинга
    end
)

-- Update player list when players join/leave
local function UpdatePlayerList()
    local newPlayerList = GetPlayerList()
    TargetDropdown:SetOptions(newPlayerList)
end

Services.Players.PlayerAdded:Connect(UpdatePlayerList)
Services.Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Other Section
local OtherSection = UICreator:CreateSection(MainTab, "Other")

-- Twerk Toggle
local TwerkEnabled = false
local TwerkConnection = nil

UICreator:CreateToggle(
    OtherSection,
    "Twerk",
    false,
    function(value)
        TwerkEnabled = value
        
        if TwerkEnabled then
            TwerkConnection = Services.RunService.Heartbeat:Connect(function()
                -- Simple twerk animation by rapidly changing hip height
                local humanoid = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local currentTime = tick()
                    humanoid.HipHeight = math.sin(currentTime * 10) * 2
                end
            end)
            print("[Chromaflow] Twerk enabled")
        else
            if TwerkConnection then
                TwerkConnection:Disconnect()
                TwerkConnection = nil
            end
            
            -- Reset hip height
            local humanoid = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.HipHeight = 0
            end
            print("[Chromaflow] Twerk disabled")
        end
    end
)

-- Loop Achievements Toggle
local LoopAchievementsEnabled = false
local AchievementConnection = nil

UICreator:CreateToggle(
    OtherSection,
    "Loop Achievements",
    false,
    function(value)
        LoopAchievementsEnabled = value
        
        if LoopAchievementsEnabled then
            AchievementConnection = Services.RunService.Heartbeat:Connect(function()
                -- Placeholder for achievement farming logic
                -- В реальной реализации здесь будет логика для фарма достижений
            end)
            print("[Chromaflow] Loop Achievements enabled")
        else
            if AchievementConnection then
                AchievementConnection:Disconnect()
                AchievementConnection = nil
            end
            print("[Chromaflow] Loop Achievements disabled")
        end
    end
)

-- Speed Slider
local currentSpeed = 0.05
UICreator:CreateSlider(
    OtherSection,
    "Speed",
    0.05,
    0.5,
    0.05,
    0.05,
    function(value)
        currentSpeed = value
        print("[Chromaflow] Speed set to: " .. tostring(value))
        
        -- Apply speed to character if exists
        local character = Services.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16 + (value * 100) -- Base speed + bonus
        end
    end
)

-- Apply speed when character spawns
Services.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 16 + (currentSpeed * 100)
end)

print("[Chromaflow] DOORS Lobby script loaded successfully!")