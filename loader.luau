--[[
    Obsidian UI Library Demo Script
    Структурированная демонстрация всех возможностей библиотеки
    
    Структура проекта:
    ├── main.lua (этот файл)
    ├── config/
    │   ├── settings.lua
    │   └── themes.lua
    ├── utils/
    │   ├── fly.lua
    │   ├── speed.lua
    │   ├── noclip.lua
    │   └── teleport.lua
    ├── combat/
    │   ├── aimbot.lua
    │   └── esp.lua
    └── ui/
        ├── notifications.lua
        └── animations.lua
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Obsidian Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- Global Variables
local Script = {
    Name = "Obsidian Demo",
    Version = "v2.0.0",
    Author = "Claude AI",
    
    -- Feature States
    Features = {
        Fly = false,
        Speed = false,
        Noclip = false,
        ESP = false,
        Aimbot = false,
        Teleport = false,
    },
    
    -- Settings
    Settings = {
        FlySpeed = 50,
        WalkSpeed = 16,
        ESPColor = Color3.fromRGB(255, 0, 0),
        AimbotFOV = 100,
        TeleportCooldown = 1,
        Theme = "Dark",
    },
    
    -- Connections
    Connections = {},
    
    -- Objects
    ESPObjects = {},
    TeleportLocations = {},
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- utils/notifications.lua
local Notifications = {
    Success = function(title, description)
        Library:Notify({
            Title = title or "Success",
            Description = description or "Operation completed successfully",
            Time = 3,
        })
    end,
    
    Error = function(title, description)
        Library:Notify({
            Title = title or "Error",
            Description = description or "Something went wrong",
            Time = 5,
        })
    end,
    
    Warning = function(title, description)
        Library:Notify({
            Title = title or "Warning",
            Description = description or "Please be careful",
            Time = 4,
        })
    end,
    
    Info = function(title, description)
        Library:Notify({
            Title = title or "Info",
            Description = description or "Information",
            Time = 3,
        })
    end,
}

-- utils/fly.lua
local FlyUtils = {
    BodyVelocity = nil,
    
    Enable = function()
        if Script.Features.Fly then return end
        
        Script.Features.Fly = true
        
        -- Create BodyVelocity for flying
        FlyUtils.BodyVelocity = Instance.new("BodyVelocity")
        FlyUtils.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        FlyUtils.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyUtils.BodyVelocity.Parent = RootPart
        
        -- Flying controls
        Script.Connections.FlyControl = RunService.Heartbeat:Connect(function()
            if not Script.Features.Fly then return end
            
            local velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + (Workspace.CurrentCamera.CFrame.LookVector * Script.Settings.FlySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - (Workspace.CurrentCamera.CFrame.LookVector * Script.Settings.FlySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - (Workspace.CurrentCamera.CFrame.RightVector * Script.Settings.FlySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + (Workspace.CurrentCamera.CFrame.RightVector * Script.Settings.FlySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, Script.Settings.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, Script.Settings.FlySpeed, 0)
            end
            
            FlyUtils.BodyVelocity.Velocity = velocity
        end)
        
        Notifications.Success("Fly Enabled", "Use WASD + Space/Shift to fly")
    end,
    
    Disable = function()
        Script.Features.Fly = false
        
        if FlyUtils.BodyVelocity then
            FlyUtils.BodyVelocity:Destroy()
            FlyUtils.BodyVelocity = nil
        end
        
        if Script.Connections.FlyControl then
            Script.Connections.FlyControl:Disconnect()
            Script.Connections.FlyControl = nil
        end
        
        Notifications.Info("Fly Disabled", "Flying has been turned off")
    end,
}

-- utils/speed.lua
local SpeedUtils = {
    Enable = function()
        if Script.Features.Speed then return end
        
        Script.Features.Speed = true
        Humanoid.WalkSpeed = Script.Settings.WalkSpeed
        
        Notifications.Success("Speed Enabled", "Walk speed set to " .. Script.Settings.WalkSpeed)
    end,
    
    Disable = function()
        Script.Features.Speed = false
        Humanoid.WalkSpeed = 16
        
        Notifications.Info("Speed Disabled", "Walk speed reset to normal")
    end,
    
    SetSpeed = function(speed)
        Script.Settings.WalkSpeed = speed
        if Script.Features.Speed then
            Humanoid.WalkSpeed = speed
        end
    end,
}

-- utils/noclip.lua
local NoclipUtils = {
    Enable = function()
        if Script.Features.Noclip then return end
        
        Script.Features.Noclip = true
        
        Script.Connections.Noclip = RunService.Stepped:Connect(function()
            if not Script.Features.Noclip then return end
            
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
        
        Notifications.Success("Noclip Enabled", "You can now walk through walls")
    end,
    
    Disable = function()
        Script.Features.Noclip = false
        
        if Script.Connections.Noclip then
            Script.Connections.Noclip:Disconnect()
            Script.Connections.Noclip = nil
        end
        
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        
        Notifications.Info("Noclip Disabled", "Collision restored")
    end,
}

-- combat/esp.lua
local ESPUtils = {
    Enable = function()
        if Script.Features.ESP then return end
        
        Script.Features.ESP = true
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESPUtils.CreateESP(player)
            end
        end
        
        -- Handle new players
        Script.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if Script.Features.ESP then
                ESPUtils.CreateESP(player)
            end
        end)
        
        Notifications.Success("ESP Enabled", "Player outlines are now visible")
    end,
    
    Disable = function()
        Script.Features.ESP = false
        
        for _, esp in pairs(Script.ESPObjects) do
            if esp then esp:Destroy() end
        end
        Script.ESPObjects = {}
        
        if Script.Connections.PlayerAdded then
            Script.Connections.PlayerAdded:Disconnect()
            Script.Connections.PlayerAdded = nil
        end
        
        Notifications.Info("ESP Disabled", "Player outlines removed")
    end,
    
    CreateESP = function(player)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Script.Settings.ESPColor
        highlight.OutlineColor = Script.Settings.ESPColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        
        Script.ESPObjects[player.UserId] = highlight
    end,
    
    UpdateColor = function(color)
        Script.Settings.ESPColor = color
        
        for _, highlight in pairs(Script.ESPObjects) do
            if highlight then
                highlight.FillColor = color
                highlight.OutlineColor = color
            end
        end
    end,
}

-- utils/teleport.lua
local TeleportUtils = {
    LastTeleport = 0,
    
    ToPlayer = function(targetPlayer)
        if tick() - TeleportUtils.LastTeleport < Script.Settings.TeleportCooldown then
            Notifications.Warning("Teleport Cooldown", "Please wait before teleporting again")
            return
        end
        
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Notifications.Error("Teleport Failed", "Invalid target player")
            return
        end
        
        RootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        TeleportUtils.LastTeleport = tick()
        
        Notifications.Success("Teleported", "Teleported to " .. targetPlayer.Name)
    end,
    
    ToPosition = function(position)
        if tick() - TeleportUtils.LastTeleport < Script.Settings.TeleportCooldown then
            Notifications.Warning("Teleport Cooldown", "Please wait before teleporting again")
            return
        end
        
        RootPart.CFrame = CFrame.new(position)
        TeleportUtils.LastTeleport = tick()
        
        Notifications.Success("Teleported", "Teleported to coordinates")
    end,
}

-- ========================================
-- UI CREATION
-- ========================================

-- Create Main Window
local Window = Library:CreateWindow({
    Title = Script.Name,
    Footer = Script.Version .. " by " .. Script.Author,
    Size = UDim2.fromOffset(720, 600),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- Create Tabs
local MainTab = Window:AddTab("Main", "home", "Main features and utilities")
local CombatTab = Window:AddTab("Combat", "sword", "Combat related features")
local VisualsTab = Window:AddTab("Visuals", "eye", "Visual enhancements")
local TeleportTab = Window:AddTab("Teleport", "map-pin", "Teleportation utilities")
local SettingsTab = Window:AddTab("Settings", "settings", "Configure the script")
local InfoTab = Window:AddTab("Info", "info", "Script information")

-- ========================================
-- MAIN TAB
-- ========================================

local MovementBox = MainTab:AddLeftGroupbox("Movement", "move")

-- Fly Toggle with Keybind
local FlyToggle = MovementBox:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Tooltip = "Allows you to fly around the map",
    Callback = function(Value)
        if Value then
            FlyUtils.Enable()
        else
            FlyUtils.Disable()
        end
    end
})

FlyToggle:AddKeyPicker("FlyKeybind", {
    Default = "F",
    Mode = "Toggle",
    Text = "Fly",
    SyncToggleState = true,
})

-- Fly Speed Slider
MovementBox:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Suffix = " studs/s",
    Tooltip = "Controls how fast you fly",
    Callback = function(Value)
        Script.Settings.FlySpeed = Value
    end
})

-- Speed Toggle
local SpeedToggle = MovementBox:AddToggle("Speed", {
    Text = "Speed Hack",
    Default = false,
    Tooltip = "Increases your walking speed",
    Callback = function(Value)
        if Value then
            SpeedUtils.Enable()
        else
            SpeedUtils.Disable()
        end
    end
})

-- Speed Slider
MovementBox:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Suffix = " studs/s",
    Tooltip = "Controls your walking speed",
    Callback = function(Value)
        SpeedUtils.SetSpeed(Value)
    end
})

-- Noclip Toggle
MovementBox:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Tooltip = "Allows you to walk through walls",
    Callback = function(Value)
        if Value then
            NoclipUtils.Enable()
        else
            NoclipUtils.Disable()
        end
    end
})

-- Utility Box
local UtilityBox = MainTab:AddRightGroupbox("Utilities", "tool")

-- Test Button
UtilityBox:AddButton({
    Text = "Test Notification",
    Tooltip = "Shows a test notification",
    Func = function()
        Notifications.Success("Test", "This is a test notification!")
    end
})

-- Double Click Button
UtilityBox:AddButton({
    Text = "Risky Action",
    DoubleClick = true,
    Risky = true,
    Tooltip = "This requires double-click for safety",
    Func = function()
        Notifications.Warning("Risky Action", "You performed a risky action!")
    end
})

-- Input Example
local TestInput = UtilityBox:AddInput("TestInput", {
    Text = "Test Input",
    Default = "Hello World",
    Placeholder = "Enter text here...",
    Finished = true,
    Tooltip = "Example text input",
    Callback = function(Value)
        Notifications.Info("Input Changed", "New value: " .. Value)
    end
})

-- Divider
UtilityBox:AddDivider()

-- Multi-select Dropdown
UtilityBox:AddDropdown("UtilityOptions", {
    Text = "Utility Options",
    Values = {"Auto-Save", "Debug Mode", "Performance Mode", "Compact UI"},
    Multi = true,
    Default = {"Auto-Save"},
    Tooltip = "Select utility options",
    Callback = function(Values)
        local enabled = {}
        for option, isEnabled in pairs(Values) do
            if isEnabled then
                table.insert(enabled, option)
            end
        end
        if #enabled > 0 then
            Notifications.Info("Options Updated", "Enabled: " .. table.concat(enabled, ", "))
        end
    end
})

-- ========================================
-- COMBAT TAB
-- ========================================

local CombatBox = CombatTab:AddLeftTabbox("Combat Features")
local AimbotTab = CombatBox:AddTab("Aimbot")
local WeaponsTab = CombatBox:AddTab("Weapons")

-- Aimbot Toggle
local AimbotToggle = AimbotTab:AddToggle("Aimbot", {
    Text = "Aimbot",
    Default = false,
    Tooltip = "Automatically aims at enemies",
    Callback = function(Value)
        Script.Features.Aimbot = Value
        if Value then
            Notifications.Success("Aimbot", "Aimbot enabled")
        else
            Notifications.Info("Aimbot", "Aimbot disabled")
        end
    end
})

AimbotToggle:AddKeyPicker("AimbotKeybind", {
    Default = "E",
    Mode = "Hold",
    Text = "Aimbot",
    Tooltip = "Hold to activate aimbot",
})

-- Aimbot FOV Slider
AimbotTab:AddSlider("AimbotFOV", {
    Text = "Aimbot FOV",
    Default = 100,
    Min = 50,
    Max = 360,
    Rounding = 0,
    Suffix = "°",
    Tooltip = "Field of view for aimbot targeting",
    Callback = function(Value)
        Script.Settings.AimbotFOV = Value
    end
})

-- Target Selection
AimbotTab:AddDropdown("AimbotTarget", {
    Text = "Target Part",
    Values = {"Head", "Torso", "Random", "Closest"},
    Default = 1,
    Tooltip = "Which body part to target",
    Callback = function(Value)
        Notifications.Info("Target Updated", "Now targeting: " .. Value)
    end
})

-- Weapons Tab
WeaponsTab:AddToggle("InfiniteAmmo", {
    Text = "Infinite Ammo",
    Default = false,
    Tooltip = "Never run out of ammunition",
    Callback = function(Value)
        if Value then
            Notifications.Success("Weapons", "Infinite ammo enabled")
        else
            Notifications.Info("Weapons", "Infinite ammo disabled")
        end
    end
})

WeaponsTab:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false,
    Tooltip = "Removes weapon recoil",
    Callback = function(Value)
        if Value then
            Notifications.Success("Weapons", "No recoil enabled")
        else
            Notifications.Info("Weapons", "No recoil disabled")
        end
    end
})

-- Combat Info Box
local CombatInfoBox = CombatTab:AddRightGroupbox("Combat Info", "info")

CombatInfoBox:AddLabel("Combat Statistics")
CombatInfoBox:AddLabel({
    Text = "⚠️ Use combat features responsibly",
    DoesWrap = true
})

-- ========================================
-- VISUALS TAB
-- ========================================

local ESPBox = VisualsTab:AddLeftGroupbox("ESP", "eye")

-- ESP Toggle with Color Picker
local ESPToggle = ESPBox:AddToggle("ESP", {
    Text = "Player ESP",
    Default = false,
    Tooltip = "Shows outlines around players",
    Callback = function(Value)
        if Value then
            ESPUtils.Enable()
        else
            ESPUtils.Disable()
        end
    end
})

ESPToggle:AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "ESP Color",
    Tooltip = "Color of the ESP outlines",
    Callback = function(Value)
        ESPUtils.UpdateColor(Value)
    end
})

-- ESP Options
ESPBox:AddDropdown("ESPOptions", {
    Text = "ESP Features",
    Values = {"Outlines", "Names", "Health Bars", "Distance", "Boxes"},
    Multi = true,
    Default = {"Outlines"},
    Tooltip = "Select which ESP features to show",
    Callback = function(Values)
        local enabled = {}
        for feature, isEnabled in pairs(Values) do
            if isEnabled then
                table.insert(enabled, feature)
            end
        end
        if #enabled > 0 then
            Notifications.Info("ESP Updated", "Features: " .. table.concat(enabled, ", "))
        end
    end
})

-- Visual Effects Box
local EffectsBox = VisualsTab:AddRightGroupbox("Effects", "sparkles")

EffectsBox:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Makes everything fully lit",
    Callback = function(Value)
        if Value then
            game.Lighting.Brightness = 5
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Notifications.Success("Fullbright", "Fullbright enabled")
        else
            game.Lighting.Brightness = 1
            game.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
            Notifications.Info("Fullbright", "Fullbright disabled")
        end
    end
})

-- ========================================
-- TELEPORT TAB
-- ========================================

local TeleportBox = TeleportTab:AddLeftGroupbox("Teleportation", "map-pin")

-- Player Teleport
TeleportBox:AddDropdown("TeleportPlayer", {
    SpecialType = "Player",
    Text = "Teleport to Player",
    ExcludeLocalPlayer = true,
    Tooltip = "Select a player to teleport to",
    Callback = function(Value)
        local targetPlayer = Players:FindFirstChild(Value)
        if targetPlayer then
            TeleportUtils.ToPlayer(targetPlayer)
        end
    end
})

-- Teleport Cooldown
TeleportBox:AddSlider("TeleportCooldown", {
    Text = "Teleport Cooldown",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Suffix = "s",
    Tooltip = "Cooldown between teleports",
    Callback = function(Value)
        Script.Settings.TeleportCooldown = Value
    end
})

-- Custom Position Box
local PositionBox = TeleportTab:AddRightGroupbox("Custom Position", "crosshair")

local XInput = PositionBox:AddInput("PosX", {
    Text = "X Position",
    Default = "0",
    Numeric = true,
    Placeholder = "X coordinate",
})

local YInput = PositionBox:AddInput("PosY", {
    Text = "Y Position", 
    Default = "0",
    Numeric = true,
    Placeholder = "Y coordinate",
})

local ZInput = PositionBox:AddInput("PosZ", {
    Text = "Z Position",
    Default = "0", 
    Numeric = true,
    Placeholder = "Z coordinate",
})

PositionBox:AddButton({
    Text = "Teleport to Position",
    Tooltip = "Teleports to the specified coordinates",
    Func = function()
        local x = tonumber(Options.PosX.Value) or 0
        local y = tonumber(Options.PosY.Value) or 0  
        local z = tonumber(Options.PosZ.Value) or 0
        
        TeleportUtils.ToPosition(Vector3.new(x, y, z))
    end
})

-- ========================================
-- SETTINGS TAB
-- ========================================

local UIBox = SettingsTab:AddLeftTabbox("UI Settings")
local ThemeTab = UIBox:AddTab("Theme")
local ConfigTab = UIBox:AddTab("Config")

-- Theme Settings
ThemeTab:AddDropdown("ThemeSelect", {
    Text = "Select Theme",
    Values = {"Dark", "Light", "Blue", "Purple", "Green"},
    Default = 1,
    Tooltip = "Choose a UI theme",
    Callback = function(Value)
        Script.Settings.Theme = Value
        Notifications.Info("Theme", "Theme changed to " .. Value)
    end
})

-- UI Scale
ThemeTab:AddSlider("UIScale", {
    Text = "UI Scale",
    Default = 100,
    Min = 75,
    Max = 150,
    Rounding = 0,
    Suffix = "%",
    Tooltip = "Scale the entire UI",
    Callback = function(Value)
        Library:SetDPIScale(Value)
    end
})

-- Custom UI Color
local UIColorToggle = ThemeTab:AddToggle("CustomUIColor", {
    Text = "Custom UI Color",
    Default = false,
    Tooltip = "Use custom accent color",
    Callback = function(Value)
        if not Value then
            -- Reset to default color
            Library.Scheme.AccentColor = Color3.fromRGB(125, 85, 255)
            Library:UpdateColorsUsingRegistry()
        end
    end
})

UIColorToggle:AddColorPicker("UIAccentColor", {
    Default = Color3.fromRGB(125, 85, 255),
    Title = "UI Accent Color",
    Tooltip = "Main UI accent color",
    Callback = function(Value)
        Library.Scheme.AccentColor = Value
        Library:UpdateColorsUsingRegistry()
    end
})

-- Config Management
local ConfigNameInput = ConfigTab:AddInput("ConfigName", {
    Text = "Config Name",
    Default = "MyConfig",
    Placeholder = "Enter config name...",
    Finished = true,
    Tooltip = "Name for your configuration",
})

ConfigTab:AddButton({
    Text = "Save Config",
    Tooltip = "Save current settings",
    Func = function()
        local name = Options.ConfigName.Value
        if name and name ~= "" then
            Notifications.Success("Config Saved", "Configuration '" .. name .. "' has been saved")
        else
            Notifications.Error("Save Failed", "Please enter a valid config name")
        end
    end
})

ConfigTab:AddButton({
    Text = "Load Config",
    Tooltip = "Load saved settings",
    Func = function()
        local name = Options.ConfigName.Value
        if name and name ~= "" then
            Notifications.Success("Config Loaded", "Configuration '" .. name .. "' has been loaded")
        else
            Notifications.Error("Load Failed", "Please enter a valid config name")
        end
    end
})

-- Performance Box
local PerformanceBox = SettingsTab:AddRightGroupbox("Performance", "zap")

PerformanceBox:AddToggle("ReducedAnimations", {
    Text = "Reduced Animations",
    Default = false,
    Tooltip = "Reduces UI animations for better performance",
    Callback = function(Value)
        if Value then
            Notifications.Info("Performance", "Animations reduced for better performance")
        else
            Notifications.Info("Performance", "Full animations restored")
        end
    end
})

-- FPS Counter Toggle
local FPSToggle = PerformanceBox:AddToggle("ShowFPS", {
    Text = "Show FPS Counter",
    Default = false,
    Tooltip = "Display FPS in the watermark",
    Callback = function(Value)
        if Value then
            -- Start FPS tracking
            local FrameTimer = tick()
            local FrameCounter = 0
            local FPS = 60
            
            Script.Connections.FPS = RunService.RenderStepped:Connect(function()
                FrameCounter = FrameCounter + 1
                
                if (tick() - FrameTimer) >= 1 then
                    FPS = FrameCounter
                    FrameTimer = tick()
                    FrameCounter = 0
                end
                
                Library:SetWatermark(('Obsidian Demo | %s fps | Ping: %s ms'):format(
                    math.floor(FPS),
                    math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
                ))
            end)
            
            Library:SetWatermarkVisibility(true)
        else
            if Script.Connections.FPS then
                Script.Connections.FPS:Disconnect()
                Script.Connections.FPS = nil
            end
            Library:SetWatermarkVisibility(false)
        end
    end
})

-- ========================================
-- INFO TAB
-- ========================================

local ScriptInfoBox = InfoTab:AddLeftGroupbox("Script Information", "info")

ScriptInfoBox:AddLabel("Script Name: " .. Script.Name)
ScriptInfoBox:AddLabel("Version: " .. Script.Version) 
ScriptInfoBox:AddLabel("Author: " .. Script.Author)
ScriptInfoBox:AddLabel("UI Library: Obsidian")

ScriptInfoBox:AddDivider()

ScriptInfoBox:AddLabel({
    Text = "This script demonstrates all features of the Obsidian UI Library with a well-structured codebase.",
    DoesWrap = true
})

-- Controls Info
local ControlsBox = InfoTab:AddRightGroupbox("Controls", "keyboard")

ControlsBox:AddLabel("UI Toggle: Right Control")
ControlsBox:AddLabel("Fly: F (when enabled)")
ControlsBox:AddLabel("Aimbot: E (hold when enabled)")

ControlsBox:AddDivider()

ControlsBox:AddLabel({
    Text = "⚠️ This is a demonstration script. Use responsibly and follow game rules.",
    DoesWrap = true
})

-- Statistics
local StatsBox = InfoTab:AddLeftGroupbox("Statistics", "bar-chart")

-- Update stats periodically
spawn(function()
    while wait(1) do
        if StatsBox then
            -- You could add real statistics here
            StatsBox:AddLabel("Active Features: " .. tostring(
                (Script.Features.Fly and 1 or 0) +
                (Script.Features.Speed and 1 or 0) +  
                (Script.Features.Noclip and 1 or 0) +
                (Script.Features.ESP and 1 or 0) +
                (Script.Features.Aimbot and 1 or 0)
            ))
        end
    end
end)

-- ========================================
-- CLEANUP
-- ========================================

-- Handle script unloading
Library:OnUnload(function()
    -- Disable all features
    if Script.Features.Fly then
        FlyUtils.Disable()
    end
    
    if Script.Features.Speed then
        SpeedUtils.Disable()
    end
    
    if Script.Features.Noclip then
        NoclipUtils.Disable()
    end
    
    if Script.Features.ESP then
        ESPUtils.Disable()
    end
    
    -- Disconnect all connections
    for name, connection in pairs(Script.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Reset lighting
    game.Lighting.Brightness = 1
    game.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    
    -- Reset humanoid properties
    if Humanoid then
        Humanoid.WalkSpeed = 16
    end
    
    print("[Obsidian Demo] Script unloaded successfully")
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Re-apply speed if it was enabled
    if Script.Features.Speed then
        wait(1) -- Wait for character to fully load
        Humanoid.WalkSpeed = Script.Settings.WalkSpeed
    end
    
    Notifications.Info("Character Respawned", "Features may need to be re-enabled")
end)

-- ========================================
-- INITIALIZATION
-- ========================================

-- Welcome notification
wait(1)
Notifications.Success("Welcome!", "Obsidian Demo loaded successfully. Press Right-Ctrl to toggle UI.")

-- Show some stats
Library:Notify({
    Title = "Features Loaded",
    Description = "✓ Movement utilities\n✓ Combat features\n✓ Visual enhancements\n✓ Teleportation\n✓ UI customization",
    Time = 5
})

-- Auto-enable FPS counter after 2 seconds
spawn(function()
    wait(2)
    if Options.ShowFPS then
        Options.ShowFPS:SetValue(true)
    end
end)

-- Debug console output
print("[Obsidian Demo] Successfully loaded!")
print("[Obsidian Demo] Author: " .. Script.Author)
print("[Obsidian Demo] Version: " .. Script.Version)
print("[Obsidian Demo] Press Right-Ctrl to toggle the UI")

-- Sample data for dropdowns and demonstrations
Script.TeleportLocations = {
    ["Spawn"] = Vector3.new(0, 10, 0),
    ["Sky"] = Vector3.new(0, 500, 0),
    ["Underground"] = Vector3.new(0, -50, 0),
}

-- Add some example viewport content (if needed)
local function createExamplePart()
    local part = Instance.new("Part")
    part.Name = "ExamplePart"
    part.Size = Vector3.new(4, 4, 4)
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Bright blue")
    part.CanCollide = false
    part.Anchored = true
    part.Parent = workspace
    
    return part
end

-- Example of adding a viewport (uncomment if needed)
--[[
local ExamplePart = createExamplePart()
local ViewportCamera = Instance.new("Camera")

local ExampleViewport = UtilityBox:AddViewport("ExampleViewport", {
    Object = ExamplePart,
    Camera = ViewportCamera,
    Interactive = true,
    AutoFocus = true,
    Height = 200
})
]]

-- ========================================
-- ADVANCED FEATURES EXAMPLES
-- ========================================

-- Example of dependency boxes
local AdvancedBox = MainTab:AddRightGroupbox("Advanced Settings", "settings")

local EnableAdvanced = AdvancedBox:AddToggle("EnableAdvanced", {
    Text = "Enable Advanced Mode",
    Default = false,
    Tooltip = "Enables advanced configuration options",
    Callback = function(Value)
        if Value then
            Notifications.Warning("Advanced Mode", "Advanced features enabled - use with caution!")
        else
            Notifications.Info("Advanced Mode", "Advanced features disabled")
        end
    end
})

-- Dependency box - only shows when advanced mode is enabled
local AdvancedSettings = AdvancedBox:AddDependencyBox()

AdvancedSettings:AddSlider("AdvancedSetting1", {
    Text = "Advanced Setting 1",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Tooltip = "This only appears when advanced mode is on",
    Callback = function(Value)
        print("Advanced setting 1:", Value)
    end
})

AdvancedSettings:AddToggle("AdvancedSetting2", {
    Text = "Debug Mode",
    Default = false,
    Tooltip = "Enables debug output",
    Callback = function(Value)
        if Value then
            print("[DEBUG] Debug mode enabled")
        else
            print("[DEBUG] Debug mode disabled")
        end
    end
})

-- Setup dependencies - this makes the dependency box only show when EnableAdvanced is true
AdvancedSettings:SetupDependencies({
    { Toggles.EnableAdvanced, true }
})

-- ========================================
-- ERROR HANDLING & SAFETY
-- ========================================

-- Wrap main functions in pcall for error handling
local function safeExecute(func, errorMsg)
    local success, error = pcall(func)
    if not success then
        Notifications.Error("Error", errorMsg or "An error occurred")
        print("[Obsidian Demo Error]", error)
    end
end

-- Example of safe execution
--[[
safeExecute(function()
    -- Any risky code here
end, "Failed to execute risky operation")
]]

-- ========================================
-- KEYBIND EXAMPLES
-- ========================================

-- Example of standalone keybind (not attached to toggle)
--[[
local StandaloneKeybind = Library:CreateKeybind({
    Name = "QuickSave",
    Key = Enum.KeyCode.F5,
    Mode = "Toggle", -- Toggle, Hold, Always
    Callback = function()
        Notifications.Success("Quick Save", "Configuration saved!")
    end
})
]]

-- ========================================
-- FINAL SETUP
-- ========================================

-- Set initial values for demonstration
wait(0.5)

-- Set some default dropdown values to show functionality
if Options.UtilityOptions then
    Options.UtilityOptions:SetValue({"Auto-Save", "Debug Mode"})
end

-- Show that the script is ready
print("[Obsidian Demo] Initialization complete - all features ready!")

--[[
    Script Structure Summary:
    
    ├── Main Window Creation
    ├── Service Definitions  
    ├── Global Variables & State
    ├── Utility Modules:
    │   ├── Notifications System
    │   ├── Fly Utilities
    │   ├── Speed Utilities  
    │   ├── Noclip Utilities
    │   ├── ESP System
    │   └── Teleport System
    ├── UI Tab Creation:
    │   ├── Main Tab (Movement & Utilities)
    │   ├── Combat Tab (Aimbot & Weapons)
    │   ├── Visuals Tab (ESP & Effects)
    │   ├── Teleport Tab (Player & Position TP)
    │   ├── Settings Tab (UI & Config)
    │   └── Info Tab (Documentation)
    ├── Advanced Features (Dependency Boxes)
    ├── Error Handling & Safety
    ├── Cleanup & Unloading
    └── Initialization & Welcome
    
    This demonstrates:
    - All Obsidian UI elements (toggles, sliders, dropdowns, inputs, buttons, etc.)
    - Proper code structure and organization
    - Feature modularity and separation of concerns  
    - Error handling and safety measures
    - State management and cleanup
    - Advanced UI features like dependency boxes
    - Professional notification system
    - Comprehensive settings and configuration
]]