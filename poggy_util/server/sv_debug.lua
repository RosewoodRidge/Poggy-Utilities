PoggyUtil = PoggyUtil or {}
PoggyUtil.DebugServer = {}

local function CanLog(category, level)
    if not Config or not Config.PoggyDebug or not Config.PoggyDebug.Enabled then return false end
    if not Config.PoggyDebug.Categories or not Config.PoggyDebug.Categories[category] then return false end
    if not Config.PoggyDebug.Level or not Config.PoggyDebug.Level[level] then return false end
    return true
end

function PoggyUtil.DebugServer.Log(category, level, message, ...)
    if not CanLog(category, level) then return end

    local formattedMessage = string.format(message, ...)
    local prefix = "^3[POGGY_UTIL_SERVER:" .. string.upper(category) .. "]^7 "
    local levelColor = "^7" -- Default: white

    if level == "ERROR" then
        levelColor = "^1" -- Red
    elseif level == "WARNING" then
        levelColor = "^3" -- Yellow
    elseif level == "INFO" then
        levelColor = "^2" -- Green
    elseif level == "TRACE" then
        levelColor = "^5" -- Magenta/Blue
    end

    local logMessage = prefix .. levelColor .. "[" .. string.upper(level) .. "]^7 " .. formattedMessage

    if Config.PoggyDebug.LogToConsole then
        print(logMessage)
    end
    -- Placeholder for LogToFile if implemented later
    -- if Config.PoggyDebug.LogToFile then
    --     -- Implement file logging logic here
    -- end
end

function PoggyUtil.DebugServer.Trace(category, message, ...)
    PoggyUtil.DebugServer.Log(category, "TRACE", message, ...)
end

function PoggyUtil.DebugServer.Info(category, message, ...)
    PoggyUtil.DebugServer.Log(category, "INFO", message, ...)
end

function PoggyUtil.DebugServer.Warning(category, message, ...)
    PoggyUtil.DebugServer.Log(category, "WARNING", message, ...)
end

function PoggyUtil.DebugServer.Error(category, message, ...)
    PoggyUtil.DebugServer.Log(category, "ERROR", message, ...)
end

-- Initial check to ensure Config is loaded
Citizen.CreateThread(function()
    while Config == nil or Config.PoggyDebug == nil do
        print("[POGGY_UTIL_SERVER:DEBUG] Waiting for Config.PoggyDebug to load...")
        Citizen.Wait(1000)
    end
    PoggyUtil.DebugServer.Info("CORE", "Server Debug Utility Initialized.")
end)
