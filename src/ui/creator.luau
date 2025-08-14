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
    
    -- Shared references
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