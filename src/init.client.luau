if getgenv().chromaflow_loading then print("[Chromaflow] Loading stopped. (CAUSE: Loading)"); return end
if getgenv().chromaflow_loaded then print("[Chromaflow] Loading stopped. (CAUSE: Already loaded)"); return end

getgenv().chromaflow_loading = true

--// Loading Wait \\--
if not game:IsLoaded() then game.Loaded:Wait() end

--// Services \\--
local Services = require("Utils/Services")
Services:GetServices({
    "Players",
    "UserInputService",
    "TextChatService",
    "ProximityPromptService",
    "PathfindingService",

    "CoreGui",
    "StarterGui",

    "Workspace",
    "Lighting",
    "ReplicatedStorage",

    "HttpService",
    "RunService",
    "SoundService",
    "TeleportService",
    "TweenService",
    "MarketplaceService"
})

--// Utils \\--
if not wax.shared.ExecutorSupport then
    wax.shared.ExecutorSupport = require("Utils/ExecutorSupport")
end

if not wax.shared.BloxstrapRPC then
    wax.shared.BloxstrapRPC = require("Utils/BloxstrapRPC")
end

if not wax.shared.FileHelper then
    wax.shared.FileHelper = require("utils/file_helper")
end

--// mspaint Loader \\--
if not wax.shared.GotPlace then
    wax.shared.GotPlace = true

    shared.ScriptName = "universal"
    shared.ScriptLoader = "universal"
    
    local Mappings = require("Mappings")
    
    local MappingID = Mappings[game.GameId]
    if MappingID then
        local Folder = MappingID["Folder"]
        local Name = MappingID["Name"] or Folder
        local GameExclusions = MappingID["Exclusions"] or {}
        local Exclusion = GameExclusions[game.PlaceId]
        
        shared.ScriptName = Name
        shared.ScriptLoader = Folder .. "/" .. MappingID["Main"]

        shared.Mapping = MappingID
        shared.ScriptFolder = Folder
        shared.ScriptExclusion = Exclusion
    
        if Exclusion then
            shared.ScriptName = Name .. " (" .. Exclusion .. ")"
            shared.ScriptLoader = Folder .. "/" .. Exclusion
        end
    end
end

--// Global functions \\--
shared.Script = {
    Functions = {}
}
shared.Hooks = {}

shared.Script.Functions.EnforceTypes = function(args, template)
    args = if typeof(args) == "table" then args else {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or (value ~= nil and typeof(argValue) ~= typeof(value)) then
            args[key] = value
        elseif typeof(value) == "table" then
            args[key] = shared.Script.Functions.EnforceTypes(argValue, value)
        end
    end

    return args
end

shared.Load = require("utils/loader")
shared.Logs = require("utils/logs")
shared.Connect = require("utils/connections")

--// Player Variables \\--
shared.Camera = workspace.CurrentCamera

shared.LocalPlayer = shared.Players.LocalPlayer
shared.PlayerGui = shared.LocalPlayer.PlayerGui
shared.PlayerScripts = shared.LocalPlayer.PlayerScripts

shared.Fly = require("utils/universal/fly")
shared.Twerk = require("utils/universal/twerk")
shared.ControlModule = require("utils/universal/control_module")

local TextChannels = shared.TextChatService:FindFirstChild("TextChannels")
if TextChannels and TextChannels:FindFirstChild("RBXGeneral") then
    shared.RBXGeneral = TextChannels.RBXGeneral
end

--// Load \\--
local UICreator = require("utils/ui/creator")
shared.Window = UICreator:CreateWindow()

require("places/loaders/" .. shared.ScriptLoader)

UICreator:CreateSettingsTab()
require("utils/ui/addons")

shared.Notify:Alert({
    Title = "OUTDATED",
    Description = "You are using a old version of mspaint that is no longer maintained.\nTo get the new loadstring join the discord!\n -> discord.gg/mspaint <-",
    Time = 30,
    ForceLinoria = true
})

getgenv().chromaflow_loading = false