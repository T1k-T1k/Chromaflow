return function(scriptType: "utils" | "tabs", name: string)
    local scriptPath = script.Parent.Parent.Places[scriptType][shared.ScriptFolder or "universal"]

    if shared.Mapping and shared.Mapping["Exclusions"] then
        local ExclusionPath = shared.ScriptExclusion or shared.Mapping["Main"]
        return require(scriptPath[ExclusionPath][name])
    end
    
    require(scriptPath[name])
end