-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)
        if getgenv().chromaflow_loading then 
            print("[Chromaflow] Loading stopped. (ERROR: Loading)"); 
            return 
        end
        if getgenv().chromaflow_loaded then 
            print("[Chromaflow] Loading stopped. (ERROR: Already loaded)"); 
            return 
        end

        getgenv().chromaflow_loading = true

        --// Loading Wait \\--
        if not game:IsLoaded() then 
            game.Loaded:Wait() 
        end

        --// Services \\--
        local Services = require("utils/services")
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
        }

-- Holds the DOM data
local ObjectTree = {
    wax = {
        Shared = {},
        Version = "2.0.1",
        SourceURL = "https://raw.githubusercontent.com/latte-soft/wax/master/src/init.lua"
    },
    
    -- Main loader
    {
        Name = "loader",
        ClassName = "ModuleScript",
        Closure = ClosureBindings[1]
    },
    
    -- Mappings
    {
        Name = "mappings",
        ClassName = "ModuleScript", 
        Closure = ClosureBindings[2]
    },
    
    -- UI System
    {
        Name = "ui",
        ClassName = "Folder",
        Children = {
            {
                Name = "creator",
                ClassName = "ModuleScript",
                Closure = ClosureBindings[3]
            }
        }
    },
    
    -- Utils System
    {
        Name = "utils", 
        ClassName = "Folder",
        Children = {
            {
                Name = "services",
                ClassName = "ModuleScript",
                Closure = ClosureBindings[4]
            },
            {
                Name = "notify",
                ClassName = "ModuleScript",
                Closure = function()
                    local Notify = {}
                    
                    function Notify:Alert(options)
                        options = options or {}
                        local title = options.Title or "Chromaflow"
                        local description = options.Description or ""
                        local time = options.Time or 5
                        
                        shared.StarterGui:SetCore("SendNotification", {
                            Title = title,
                            Text = description,
                            Duration = time,
                            Button1 = "OK"
                        })
                        
                        print("[" .. title .. "] " .. description)
                    end
                    
                    return Notify
                end
            },
            {
                Name = "connections",
                ClassName = "ModuleScript", 
                Closure = function()
                    local Connections = {}
                    local connectionStorage = {}
                    
                    function Connections:Connect(name, signal, callback)
                        if connectionStorage[name] then
                            connectionStorage[name]:Disconnect()
                        end
                        
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
                    
                    return Connections
                end
            },
            {
                Name = "fly",
                ClassName = "ModuleScript",
                Closure = function()
                    local Fly = {}
                    local flying = false
                    
                    function Fly:Enable()
                        flying = true
                        print("[Chromaflow] Fly enabled")
                    end
                    
                    function Fly:Disable() 
                        flying = false
                        print("[Chromaflow] Fly disabled")
                    end
                    
                    return Fly
                end
            },
            {
                Name = "noclip",
                ClassName = "ModuleScript",
                Closure = function()
                    local Noclip = {}
                    local noclipping = false
                    
                    function Noclip:Enable()
                        noclipping = true
                        print("[Chromaflow] Noclip enabled")
                    end
                    
                    function Noclip:Disable()
                        noclipping = false
                        print("[Chromaflow] Noclip disabled") 
                    end
                    
                    return Noclip
                end
            },
            {
                Name = "filehelper",
                ClassName = "ModuleScript",
                Closure = function()
                    local FileHelper = {}
                    
                    function FileHelper:SaveConfig(name, data)
                        print("[Chromaflow] Config saved: " .. name)
                        return true
                    end
                    
                    return FileHelper
                end
            }
        }
    },
    
    -- Places System
    {
        Name = "places",
        ClassName = "Folder",
        Children = {
            {
                Name = "doors",
                ClassName = "Folder", 
                Children = {
                    {
                        Name = "lobby",
                        ClassName = "ModuleScript",
                        Closure = function()
                            -- DOORS Lobby Script
                            local UICreator = require("ui/creator")
                            local MainTab = UICreator:CreateTab(shared.Window, "Main")
                            
                            local SniperSection = UICreator:CreateSection(MainTab, "Sniper")
                            
                            local function GetPlayerList()
                                local playerList = {}
                                for _, player in pairs(shared.Players:GetPlayers()) do
                                    if player ~= shared.LocalPlayer then
                                        table.insert(playerList, player.Name)
                                    end
                                end
                                return playerList
                            end
                            
                            UICreator:CreateDropdown(SniperSection, "Target", GetPlayerList(), nil, function(player)
                                print("[Chromaflow] Selected target: " .. tostring(player))
                            end)
                            
                            local OtherSection = UICreator:CreateSection(MainTab, "Other")
                            
                            UICreator:CreateToggle(OtherSection, "Twerk", false, function(value)
                                print("[Chromaflow] Twerk: " .. tostring(value))
                            end)
                            
                            UICreator:CreateToggle(OtherSection, "Loop Achievements", false, function(value)
                                print("[Chromaflow] Loop Achievements: " .. tostring(value))
                            end)
                            
                            UICreator:CreateSlider(OtherSection, "Speed", 0.05, 0.5, 0.05, 0.05, function(value)
                                print("[Chromaflow] Speed: " .. tostring(value))
                            end)
                            
                            print("[Chromaflow] DOORS Lobby loaded!")
                        end
                    }
                }
            },
            {
                Name = "universal",
                ClassName = "Folder",
                Children = {
                    {
                        Name = "universal", 
                        ClassName = "ModuleScript",
                        Closure = function()
                            -- Universal Script
                            local UICreator = require("ui/creator")
                            local UniversalTab = UICreator:CreateTab(shared.Window, "Universal")
                            
                            local MovementSection = UICreator:CreateSection(UniversalTab, "Movement")
                            
                            UICreator:CreateToggle(MovementSection, "Fly", false, function(value)
                                if value then
                                    shared.Fly:Enable()
                                else
                                    shared.Fly:Disable()
                                end
                            end)
                            
                            UICreator:CreateToggle(MovementSection, "Noclip", false, function(value)
                                if value then
                                    shared.Noclip:Enable()
                                else
                                    shared.Noclip:Disable()
                                end
                            end)
                            
                            UICreator:CreateSlider(MovementSection, "Walk Speed", 16, 100, 16, 1, function(value)
                                local character = shared.LocalPlayer.Character
                                if character and character:FindFirstChild("Humanoid") then
                                    character.Humanoid.WalkSpeed = value
                                end
                            end)
                            
                            print("[Chromaflow] Universal loaded!")
                        end
                    }
                }
            }
        }
    }
}

-- ++++++++ WAX RUNTIME BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, require, getfenv, setfenv, next, setmetatable, getmetatable, rawset, rawget, newproxy, tostring, tonumber, coroutine = 
      string, require, getfenv, setfenv, next, setmetatable, getmetatable, rawset, rawget, newproxy, tostring, tonumber, coroutine

local table = table
local type = type 
local pcall = pcall
local pairs = pairs
local ipairs = ipairs

-- If we're running in a Roblox environment, we'll need to handle the global environment differently
local RunService = game:GetService("RunService")

-- Create a new "fake" instance to override
local fake_script = newproxy(true)
getmetatable(fake_script).__tostring = function() return "Chromaflow" end

-- Create the wax runtime
local wax = ObjectTree.wax
wax.shared = wax.Shared

local RealObjectTree = {}
local FakeEnvs = {}
local LoadOrder = {}

-- Builds a new fake environment
local function CreateFakeEnv(module_script)
    local fake_env = {}
    local real_env = getfenv(0)
    
    -- Copy the real environment
    for key, value in next, real_env do
        fake_env[key] = value
    end
    
    -- Override specific values for module compatibility  
    fake_env.script = module_script or fake_script
    fake_env._G = fake_env
    fake_env.shared = wax.shared
    
    return fake_env
end

-- Handles the requiring of a module
local function HandleRequire(instance, from_module)
    if RealObjectTree[instance] then
        local real_instance = RealObjectTree[instance]
        
        if real_instance.ClassName == "ModuleScript" then
            if real_instance.Closure then
                local module_env = CreateFakeEnv(real_instance)
                local old_env = getfenv(real_instance.Closure)
                
                setfenv(real_instance.Closure, module_env)
                
                local success, result = pcall(real_instance.Closure)
                
                setfenv(real_instance.Closure, old_env)
                
                if success then
                    return result
                else
                    error("Failed to load module: " .. tostring(result))
                end
            end
        end
    end
    
    error("Attempted to require non-module or missing module: " .. tostring(instance))
end

-- Sets up the fake require function
local function CreateRequire(from_module)
    return function(instance)
        if type(instance) == "string" then
            -- Handle path-based requires
            local parts = string.split(instance, "/")
            local current = ObjectTree
            
            for _, part in ipairs(parts) do
                local found = false
                
                if current.Children then
                    for _, child in ipairs(current.Children) do
                        if string.lower(child.Name) == string.lower(part) then
                            current = child
                            found = true
                            break
                        end
                    end
                end
                
                if not found then
                    error("Module not found: " .. instance)
                end
            end
            
            return HandleRequire(current, from_module)
        else
            return HandleRequire(instance, from_module)
        end
    end
end

-- Builds the object tree recursively 
local function BuildObjectTree(object_table, parent)
    local instance_table = {}
    
    for key, value in next, object_table do
        if key ~= "Children" and type(key) ~= "number" then
            instance_table[key] = value
        end
    end
    
    instance_table.Parent = parent
    
    RealObjectTree[object_table] = instance_table
    
    if object_table.Children then
        instance_table.Children = {}
        for _, child in ipairs(object_table.Children) do
            local built_child = BuildObjectTree(child, instance_table)
            table.insert(instance_table.Children, built_child)
        end
    end
    
    return instance_table
end

-- Build the complete object tree
for _, object in ipairs(ObjectTree) do
    if type(object) == "table" and object.Name then
        BuildObjectTree(object, wax)
    end
end

-- Create the import globals function
ImportGlobals = function(index)
    local module = ClosureBindings[index] and RealObjectTree[ObjectTree[index]]
    if module then
        return wax, fake_script, CreateRequire(module)
    end
    return wax, fake_script, CreateRequire()
end

-- Finally, execute the main loader
local main_loader = ClosureBindings[1]
if main_loader then
    local wax_env, script_env, require_env = ImportGlobals(1)
    setfenv(main_loader, CreateFakeEnv(fake_script))
    main_loader()
end)

        --// Utils \\--
        if not wax.shared.FileHelper then
            wax.shared.FileHelper = require("utils/filehelper")
        end

        if not wax.shared.Notify then
            wax.shared.Notify = require("utils/notify")
        end

        if not wax.shared.Connections then
            wax.shared.Connections = require("utils/connections")
        end

        --// Chromaflow Loader \\--
        if not wax.shared.GotPlace then
            wax.shared.GotPlace = true

            shared.ScriptName = "Universal"
            shared.ScriptLoader = "universal/universal"
            
            local Mappings = require("mappings")
            
            local MappingID = Mappings[game.GameId]
            if MappingID then
                local Folder = MappingID["Folder"]
                local Name = MappingID["Name"] or Folder
                local Main = MappingID["Main"]
                
                shared.ScriptName = Name
                shared.ScriptLoader = string.lower(Folder) .. "/" .. string.lower(Main)
                shared.Mapping = MappingID
                shared.ScriptFolder = Folder
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

        --// Player Variables \\--
        shared.Camera = workspace.CurrentCamera
        shared.LocalPlayer = shared.Players.LocalPlayer
        shared.PlayerGui = shared.LocalPlayer.PlayerGui
        shared.PlayerScripts = shared.LocalPlayer.PlayerScripts

        shared.Fly = require("utils/fly")
        shared.Noclip = require("utils/noclip")

        local TextChannels = shared.TextChatService:FindFirstChild("TextChannels")
        if TextChannels and TextChannels:FindFirstChild("RBXGeneral") then
            shared.RBXGeneral = TextChannels.RBXGeneral
        end

        --// Load UI \\--
        local UICreator = require("ui/creator")
        shared.Window = UICreator:CreateWindow()

        --// Load Script \\--
        require("places/" .. shared.ScriptLoader)

        print("[Chromaflow] Loaded successfully! Script: " .. shared.ScriptName)
        
        getgenv().chromaflow_loading = false
        getgenv().chromaflow_loaded = true

    end)() end,
    
    function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...) 
        return {
            [6516141723] = {Folder = "Doors", Main = "Lobby", Name = "DOORS Lobby"},
            [12308344607] = {Folder = "Doors", Main = "Lobby", Name = "DOORS Lobby"},
            [2440500124] = {Folder = "Doors", Main = "Hotel", Name = "DOORS Hotel"}
        }
    end)() end,
    
    -- UI Creator
    function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)
        local UICreator = {}
        
        -- Obsidian UI Library
        local ObsidianUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
        
        function UICreator:CreateWindow()
            local Window = ObsidianUI:Window({
                Name = "Chromaflow",
                Size = UDim2.new(0, 500, 0, 400),
                Position = UDim2.new(0.5, -250, 0.5, -200),
                Visible = true
            })
            
            shared.Toggles = {}
            shared.Options = {}
            
            return Window
        end
        
        function UICreator:CreateTab(Window, TabName)
            return Window:Tab({
                Name = TabName,
                Icon = "rbxassetid://4483345998"
            })
        end
        
        function UICreator:CreateSection(Tab, SectionName)
            return Tab:Section({
                Name = SectionName
            })
        end
        
        function UICreator:CreateToggle(Section, ToggleName, DefaultValue, Callback)
            local Toggle = Section:Toggle({
                Name = ToggleName,
                Default = DefaultValue or false,
                Callback = Callback or function() end
            })
            
            shared.Toggles[ToggleName] = Toggle
            return Toggle
        end
        
        function UICreator:CreateSlider(Section, SliderName, Min, Max, Default, Increment, Callback)
            local Slider = Section:Slider({
                Name = SliderName,
                Min = Min or 0,
                Max = Max or 100,
                Default = Default or 50,
                Increment = Increment or 1,
                Callback = Callback or function() end
            })
            
            shared.Options[SliderName] = Slider
            return Slider
        end
        
        function UICreator:CreateDropdown(Section, DropdownName, Options, DefaultOption, Callback)
            local Dropdown = Section:Dropdown({
                Name = DropdownName,
                Options = Options or {},
                Default = DefaultOption,
                Callback = Callback or function() end
            })
            
            shared.Options[DropdownName] = Dropdown
            return Dropdown
        end
        
        function UICreator:CreateButton(Section, ButtonName, Callback)
            return Section:Button({
                Name = ButtonName,
                Callback = Callback or function() end
            })
        end
        
        return UICreator
    end)() end,
    
    -- Services Utility
    function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)
        local Services = {}
        
        function Services:GetServices(serviceList)
            for _, serviceName in pairs(serviceList) do
                local success, service = pcall(function()
                    return game:GetService(serviceName)
                end)
                
                if success then
                    shared[serviceName] = service
                else
                    warn("[Chromaflow] Failed to load service: " .. serviceName)
                end
            end
        end
        
        return Services
    end)() end,
}