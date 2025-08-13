-- loader.luau: Chromaflow Loader for DOORS Lobby

-- Локализация функций для оптимизации
local string, table, pcall, task = string, table, pcall, task
local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end

-- Поддержка Lune
local task_defer = task.defer or function(f, ...) coroutine.wrap(f)(...) end

-- Виртуальный DOM
local RefBindings = {} -- [RefId] = RealObject
local RefChildren = {} -- [Ref] = {ChildrenRef}
local ScriptClosures = {} -- [Ref] = Closure
local StoredModuleValues = {} -- [Ref] = ModuleResult
local ScriptsToRun = {}
local SharedEnvironment = {} -- Для wax.shared

-- Модули
local ClosureBindings = {
    [1] = function() -- main.luau
        local wax, script, require = ImportGlobals(1)
        return function()
            if getgenv().chromaflow_loading then
                print("[Chromaflow] Loading stopped (ERROR: Already loading)")
                return
            end
            if getgenv().chromaflow_loaded then
                print("[Chromaflow] Loading stopped (ERROR: Already loaded)")
                return
            end
            getgenv().chromaflow_loading = true

            -- Ожидание загрузки игры
            if not game:IsLoaded() then game.Loaded:Wait() end

            -- Проверка DOORS Lobby
            local DOORS_LOBBY_IDS = {6516141723, 12308344607}
            if not table.find(DOORS_LOBBY_IDS, game.GameId) then
                error("[Chromaflow] This script only supports DOORS Lobby")
            end

            -- Создание папок
            wax.shared.FileHelper.CreateFolder("Chromaflow")
            wax.shared.FileHelper.CreateFolder("Chromaflow/config")
            wax.shared.FileHelper.CreateFolder("Chromaflow/assets")

            -- Сервисы
            wax.shared.Services = require("utils/services")
            wax.shared.LocalPlayer = wax.shared.Services.Players.LocalPlayer
            wax.shared.PlayerGui = wax.shared.LocalPlayer.PlayerGui
            wax.shared.Camera = workspace.CurrentCamera

            -- Загрузка Obsidian UI
            wax.shared.Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
            wax.shared.Window = require("ui/creator")

            -- Загрузка конфига
            wax.shared.Settings = wax.shared.FileHelper.LoadConfig("Chromaflow/config/settings.luau") or {
                FlyEnabled = false,
                NoclipEnabled = false
            }

            -- Утилиты
            wax.shared.Notify = require("utils/notify")
            wax.shared.Connections = require("utils/connections")

            -- Загрузка DOORS Lobby
            require("places/doors/lobby")

            -- Уведомление
            wax.shared.Notify:Alert({
                Title = "Chromaflow Loaded",
                Description = "Welcome to Chromaflow for DOORS Lobby!",
                Time = 5
            })

            -- Выгрузка
            wax.shared.Library = {
                OnUnload = function()
                    wax.shared.FileHelper.SaveConfig("Chromaflow/config/settings.luau", wax.shared.Settings)
                    for _, connection in pairs(wax.shared.Connections) do
                        connection:Disconnect()
                    end
                end
            }

            getgenv().chromaflow_loading = false
            getgenv().chromaflow_loaded = true
        end
    end,
    [2] = function() -- utils/filehelper.luau
        local wax, script, require = ImportGlobals(2)
        return function()
            local HttpService = game:GetService("HttpService")
            local FileHelper = {}

            function FileHelper.CreateFolder(path)
                if isfolder and makefolder and not isfolder(path) then
                    makefolder(path)
                end
            end

            function FileHelper.SaveConfig(path, data)
                if writefile then
                    writefile(path, HttpService:JSONEncode(data))
                end
            end

            function FileHelper.LoadConfig(path)
                if readfile and isfile(path) then
                    return HttpService:JSONDecode(readfile(path))
                end
                return nil
            end

            function FileHelper.LoadAsset(path)
                if isfile and isfile("Chromaflow/assets/" .. path) then
                    return "rbxasset://Chromaflow/assets/" .. path
                end
                return nil
            end

            wax.shared.FileHelper = FileHelper
            return FileHelper
        end
    end,
    [3] = function() -- utils/services.luau
        local wax, script, require = ImportGlobals(3)
        return function()
            local Services = {}
            local function GetServices(names)
                for _, name in ipairs(names) do
                    Services[name] = game:GetService(name)
                end
                return Services
            end
            GetServices({
                "Players",
                "UserInputService",
                "Workspace",
                "HttpService",
                "RunService",
                "TweenService"
            })
            return Services
        end
    end,
    [4] = function() -- utils/notify.luau
        local wax, script, require = ImportGlobals(4)
        return function()
            local Notify = {}
            function Notify:Alert(params)
                local title = params.Title or "Notification"
                local desc = params.Description or ""
                local time = params.Time or 5
                local gui = Instance.new("ScreenGui", wax.shared.PlayerGui)
                local frame = Instance.new("Frame", gui)
                frame.Size = UDim2.new(0, 200, 0, 100)
                frame.Position = UDim2.new(0.5, -100, 0.8, -50)
                local text = Instance.new("TextLabel", frame)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.Text = title .. "\n" .. desc
                text.TextScaled = true
                task.wait(time)
                gui:Destroy()
            end
            wax.shared.Notify = Notify
            return Notify
        end
    end,
    [5] = function() -- utils/connections.luau
        local wax, script, require = ImportGlobals(5)
        return function()
            local Connections = {}
            local function Connect(signal, callback)
                local connection = signal:Connect(callback)
                table_insert(Connections, connection)
                return connection
            end
            wax.shared.Connections = Connections
            return { Connect = Connect }
        end
    end,
    [6] = function() -- ui/creator.luau
        local wax, script, require = ImportGlobals(6)
        return function()
            local Window = wax.shared.Obsidian:CreateWindow({ Title = "Chromaflow - DOORS Lobby" })
            Window:AddTab({ Name = "Main" })
            Window:AddTab({ Name = "Exploits" })
            Window:AddTab({ Name = "Visuals" })
            require("ui/tabs/main")
            require("ui/tabs/exploits")
            require("ui/tabs/visuals")
            wax.shared.Window = Window
            return Window
        end
    end,
    [7] = function() -- ui/tabs/main.luau
        local wax, script, require = ImportGlobals(7)
        return function()
            local Window = wax.shared.Window
            local MainTab = Window:GetTab("Main")
            MainTab:AddToggle({
                Name = "Enable Fly",
                Value = wax.shared.Settings.FlyEnabled,
                Callback = function(state)
                    wax.shared.Settings.FlyEnabled = state
                    wax.shared.FileHelper.SaveConfig("Chromaflow/config/settings.luau", wax.shared.Settings)
                    wax.shared.Notify:Alert({
                        Title = "Fly",
                        Description = state and "Fly enabled" or "Fly disabled",
                        Time = 3
                    })
                end
            })
        end
    end,
    [8] = function() -- ui/tabs/exploits.luau
        local wax, script, require = ImportGlobals(8)
        return function()
            local Window = wax.shared.Window
            local ExploitsTab = Window:GetTab("Exploits")
            ExploitsTab:AddToggle({
                Name = "Enable Noclip",
                Value = wax.shared.Settings.NoclipEnabled,
                Callback = function(state)
                    wax.shared.Settings.NoclipEnabled = state
                    wax.shared.FileHelper.SaveConfig("Chromaflow/config/settings.luau", wax.shared.Settings)
                    wax.shared.Notify:Alert({
                        Title = "Noclip",
                        Description = state and "Noclip enabled" or "Noclip disabled",
                        Time = 3
                    })
                end
            })
        end
    end,
    [9] = function() -- ui/tabs/visuals.luau
        local wax, script, require = ImportGlobals(9)
        return function()
            local Window = wax.shared.Window
            local VisualsTab = Window:GetTab("Visuals")
            VisualsTab:AddButton({
                Name = "Test Notification",
                Callback = function()
                    wax.shared.Notify:Alert({
                        Title = "Test",
                        Description = "This is a test notification",
                        Time = 5
                    })
                end
            })
        end
    end,
    [10] = function() -- places/doors/lobby.luau
        local wax, script, require = ImportGlobals(10)
        return function()
            -- Логика для DOORS Lobby
            wax.shared.Notify:Alert({
                Title = "DOORS Lobby",
                Description = "Loaded specific features for DOORS Lobby",
                Time = 5
            })
        end
    end,
}

-- Создание виртуального инстанса
local function CreateRef(className, name, parent)
    local Ref = {}
    local Children = setmetatable({}, {__mode = "k"})
    local RefMetatable = {
        __index = function(_, index)
            if index == "ClassName" then return className
            elseif index == "Name" then return name
            elseif index == "Parent" then return parent
            elseif index == "GetChildren" then
                return function() local t = {} for child in pairs(Children) do table_insert(t, child) end return t end
            elseif index == "FindFirstChild" then
                return function(_, n) for child in pairs(Children) do if child.Name == n then return child end end
            end
            error(index .. " is not a valid member of " .. className)
        end,
        __newindex = function(_, index, value)
            if index == "Name" then name = value
            elseif index == "Parent" then
                if parent then RefChildren[parent][Ref] = nil end
                parent = value
                if parent then RefChildren[parent][Ref] = true end
            else
                error(index .. " is read-only")
            end
        end,
        __tostring = function() return name end
    }
    setmetatable(Ref, RefMetatable)
    RefChildren[Ref] = Children
    if parent then RefChildren[parent][Ref] = true end
    return Ref
end

-- Виртуальный DOM
local ObjectTree = {
    {1, 1, {"Chromaflow"}, {
        {2, 2, {"filehelper"}, {}},
        {3, 2, {"services"}, {}},
        {4, 2, {"notify"}, {}},
        {5, 2, {"connections"}, {}},
        {6, 2, {"creator"}, {}},
        {7, 2, {"main"}, {}},
        {8, 2, {"exploits"}, {}},
        {9, 2, {"visuals"}, {}},
        {10, 2, {"lobby"}, {}},
    }}
}

-- Создание DOM
local Root = CreateRef("Folder", "Chromaflow")
for _, obj in ipairs(ObjectTree) do
    local function CreateRefFromObject(obj, parent)
        local refId, classId, props, children = obj[1], obj[2], obj[3], obj[4]
        local className = ({[1]="Folder",[2]="ModuleScript"})[classId]
        local name = props[1] or className
        local ref = CreateRef(className, name, parent)
        RefBindings[refId] = ref
        if children then
            for _, child in ipairs(children) do
                CreateRefFromObject(child, ref)
            end
        end
    end
    CreateRefFromObject(obj, Root)
end

-- Загрузка скриптов
for refId, closure in pairs(ClosureBindings) do
    local ref = RefBindings[refId]
    ScriptClosures[ref] = closure
    if ref.ClassName == "LocalScript" or ref.ClassName == "Script" then
        table_insert(ScriptsToRun, ref)
    end
end

-- Кастомный require
local function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value) SharedEnvironment[index] = value end,
        __len = function() return #SharedEnvironment end,
        __iter = function() return next, SharedEnvironment end
    }))
    local Global_wax = table_freeze({
        version = "1.0.0",
        envname = "Chromaflow",
        shared = WaxShared,
        script = script,
        require = require
    })
    local function Global_require(module)
        if type(module) == "table" and RefChildren[module] then
            if module.ClassName ~= "ModuleScript" then error("Attempted to call require with non-ModuleScript", 2) end
            if module == ScriptRef then error("Attempted to call require with self", 2) end
            local cached = StoredModuleValues[module]
            if cached then return unpack(cached) end
            local closure = ScriptClosures[module]
            local success, result = pcall(closure)
            if not success then error(result, 2) end
            StoredModuleValues[module] = {result}
            return result
        end
        error("Invalid require path", 2)
    end
    return Global_wax, ScriptRef, Global_require
end

-- Запуск
for _, scriptRef in ipairs(ScriptsToRun) do
    task_defer(function()
        local closure = ScriptClosures[scriptRef]
        local success, err = pcall(closure)
        if not success then
            error("[Chromaflow] Error in " .. scriptRef.Name .. ": " .. err, 0)
        end
    end)
end