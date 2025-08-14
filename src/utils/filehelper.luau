local FileHelper = {}

-- Check if executor supports file functions
local function checkFileSupport()
    return type(readfile) == "function" and type(writefile) == "function"
end

function FileHelper:WriteFile(fileName, content)
    if not checkFileSupport() then
        warn("[Chromaflow] File operations not supported by this executor")
        return false
    end
    
    local success, err = pcall(function()
        writefile(fileName, content)
    end)
    
    if not success then
        warn("[Chromaflow] Failed to write file: " .. tostring(err))
        return false
    end
    
    return true
end

function FileHelper:ReadFile(fileName)
    if not checkFileSupport() then
        warn("[Chromaflow] File operations not supported by this executor")
        return nil
    end
    
    local success, result = pcall(function()
        return readfile(fileName)
    end)
    
    if not success then
        warn("[Chromaflow] Failed to read file: " .. tostring(result))
        return nil
    end
    
    return result
end

function FileHelper:FileExists(fileName)
    if not checkFileSupport() then
        return false
    end
    
    if type(isfile) == "function" then
        return isfile(fileName)
    end
    
    -- Fallback method
    local success, _ = pcall(function()
        return readfile(fileName)
    end)
    
    return success
end

function FileHelper:CreateFolder(folderName)
    if type(makefolder) == "function" then
        local success, err = pcall(function()
            makefolder(folderName)
        end)
        
        if not success then
            warn("[Chromaflow] Failed to create folder: " .. tostring(err))
            return false
        end
        
        return true
    end
    
    warn("[Chromaflow] Folder creation not supported by this executor")
    return false
end

function FileHelper:DeleteFile(fileName)
    if type(delfile) == "function" then
        local success, err = pcall(function()
            delfile(fileName)
        end)
        
        if not success then
            warn("[Chromaflow] Failed to delete file: " .. tostring(err))
            return false
        end
        
        return true
    end
    
    warn("[Chromaflow] File deletion not supported by this executor")
    return false
end

-- Configuration system
function FileHelper:SaveConfig(configName, configData)
    local folderName = "Chromaflow"
    local fileName = folderName .. "/" .. configName .. ".json"
    
    -- Create folder if it doesn't exist
    self:CreateFolder(folderName)
    
    -- Convert config to JSON
    local jsonData = shared.HttpService:JSONEncode(configData)
    
    return self:WriteFile(fileName, jsonData)
end

function FileHelper:LoadConfig(configName)
    local folderName = "Chromaflow"
    local fileName = folderName .. "/" .. configName .. ".json"
    
    if not self:FileExists(fileName) then
        return nil
    end
    
    local jsonData = self:ReadFile(fileName)
    if not jsonData then
        return nil
    end
    
    local success, configData = pcall(function()
        return shared.HttpService:JSONDecode(jsonData)
    end)
    
    if not success then
        warn("[Chromaflow] Failed to decode config: " .. tostring(configData))
        return nil
    end
    
    return configData
end

return FileHelper