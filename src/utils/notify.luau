local Notify = {}

function Notify:Alert(options)
    options = options or {}
    local title = options.Title or "Chromaflow"
    local description = options.Description or ""
    local time = options.Time or 5
    
    -- Use StarterGui notification
    shared.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = description,
        Duration = time,
        Button1 = "OK"
    })
    
    print("[" .. title .. "] " .. description)
end

function Notify:Success(message)
    self:Alert({
        Title = "Success",
        Description = message,
        Time = 3
    })
end

function Notify:Error(message)
    self:Alert({
        Title = "Error",
        Description = message,
        Time = 5
    })
end

function Notify:Warning(message)
    self:Alert({
        Title = "Warning",
        Description = message,
        Time = 4
    })
end

return Notify