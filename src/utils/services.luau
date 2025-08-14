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