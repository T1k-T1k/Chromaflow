local UICreator = {}

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

getgenv()._internal_unload_chromaflow = function()
    getgenv().chromaflow_loading = false
    getgenv().chromaflow_loaded = false
    task.spawn(function()
        Library:Unload()
    end)
end

function UICreator:CreateWindow()
    local Window = Library:CreateWindow({
        Title = "Chromaflow v2 | " .. (shared.ScriptName or ""),
        Footer = "Roblox UI",
        Center = true,
        AutoShow = true,
        Resizable = true,
        NotifySide = "Right",
        ShowCustomCursor = true
    })

    shared.Window = Window
    shared.Notify = function(msg, duration)
        Library:Notify(msg, duration or 5)
    end

    Library:OnUnload(function()
        print("Unloading Chromaflow...")
        if shared.Fly then shared.Fly:Stop() end
        for _, connection in pairs(shared.Connections or {}) do
            connection:Disconnect()
        end
        getgenv().chromaflow_loading = false
        getgenv().chromaflow_loaded = false
        print("Chromaflow unloaded.")
    end)

    return Window
end

function UICreator:CreateSettingsTab()
    local SettingsTab = shared.Window:AddTab("UI Settings", "settings", "Customize Chromaflow")

    SettingsTab:UpdateWarningBox({
        Visible = true,
        Title = "WARNING",
        Text = "You are using a deprecated version of Chromaflow. Please update."
    })

    local MenuGroup = SettingsTab:AddLeftGroupbox("Menu", "menu")
    local CreditsGroup = SettingsTab:AddRightGroupbox("Credits", "users")

    MenuGroup:AddToggle("ExecuteOnTeleport", {
        Default = false,
        Text = "Execute On Teleport"
    })

    MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = true,
        Callback = function(val)
            Library.ShowCustomCursor = val
        end
    })

    MenuGroup:AddButton({
        Text = "Join Discord",
        Func = function()
            local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
            Inviter.Join("https://discord.com/invite/cfyMptntHr")
        end
    }):AddButton({
        Text = "Copy Link",
        Func = function()
            if setclipboard then
                setclipboard("https://discord.com/invite/cfyMptntHr")
                Library:Notify("Copied discord link to clipboard!")
            else
                Library:Notify("Discord link: https://discord.com/invite/cfyMptntHr", 10)
            end
        end
    })

    MenuGroup:AddButton({
        Text = "Unload",
        Func = function()
            Library:Unload()
        end
    })

    CreditsGroup:AddLabel("Developers:")
    CreditsGroup:AddLabel("upio - owner")
    CreditsGroup:AddLabel("deividcomsono - main script dev")
    CreditsGroup:AddLabel("mstudio45")
    CreditsGroup:AddLabel("bacalhauz")

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("Chromaflow/" .. string.lower(shared.ScriptLoader or "default"))
    if shared.SubFolder then
        SaveManager:SetSubFolder(shared.SubFolder)
    end
    SaveManager:BuildConfigSection(SettingsTab)
    ThemeManager:ApplyToTab(SettingsTab)
    SaveManager:LoadAutoloadConfig()

    return SettingsTab
end

return UICreator