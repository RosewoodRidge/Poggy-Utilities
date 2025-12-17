PoggyUtil = PoggyUtil or {}
PoggyUtil.ObjectRemoval = {}

-- Function to broadcast a removal request to all clients
function PoggyUtil.ObjectRemoval.RemoveObjectsByModel(modelName)
    if not Config.ObjectRemoval or not Config.ObjectRemoval.Enabled then
        return
    end

    PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Broadcasting request to all clients to remove model: %s", modelName)
    -- Trigger an event for all clients, telling them which model to find and remove.
    TriggerClientEvent("poggy_util:findAndRemoveByModel", -1, modelName)
end

-- Function to remove all configured objects
function PoggyUtil.ObjectRemoval.RemoveConfiguredObjects()
    if not Config.ObjectRemoval or not Config.ObjectRemoval.Enabled or not Config.ObjectRemoval.Objects then
        PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Object removal is disabled or not configured")
        return
    end

    local totalObjects = 0
    for _, objectModel in ipairs(Config.ObjectRemoval.Objects) do
        PoggyUtil.ObjectRemoval.RemoveObjectsByModel(objectModel)
        totalObjects = totalObjects + 1 -- Count models requested, not objects found
    end
    return totalObjects
end

-- Function to broadcast a dead entity cleanup request to all clients
function PoggyUtil.ObjectRemoval.CleanupDeadEntities()
    if not Config.ObjectRemoval or not Config.ObjectRemoval.Enabled then
        return
    end
    
    local deadConfig = Config.ObjectRemoval.DeadEntityCleanup
    if not deadConfig or not deadConfig.Enabled then
        PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Dead entity cleanup is disabled")
        return
    end

    PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Broadcasting dead entity cleanup request to all clients")
    TriggerClientEvent("poggy_util:cleanupDeadEntities", -1, {
        cleanPeds = deadConfig.CleanPeds,
        cleanHorses = deadConfig.CleanHorses,
        cleanAnimals = deadConfig.CleanAnimals,
        cleanWagons = deadConfig.CleanWagons
    })
end

-- Helper function to check for admin permissions (No changes needed here)
local function IsPlayerAdmin(source)
    if source == 0 then return true end
    local charInfo = PoggyUtil.Player.GetCharacterInfo(source)
    if not charInfo or not charInfo.group then return false end
    for _, adminGroup in ipairs(Config.ObjectRemoval.AdminGroups) do
        if charInfo.group == adminGroup then return true end
    end
    return false
end

-- Register admin command to manually remove objects
RegisterCommand("removeobjects", function(source, args, rawCommand)
    if not IsPlayerAdmin(source) then
        if source > 0 then
            TriggerClientEvent("chat:addMessage", source, { args = {"^1[POGGY_UTIL]", "You don't have permission."} })
        end
        return
    end

    local message
    if #args > 0 then
        for _, modelName in ipairs(args) do
            PoggyUtil.ObjectRemoval.RemoveObjectsByModel(modelName)
        end
        message = string.format("Broadcasted removal request for %d model(s).", #args)
    else
        PoggyUtil.ObjectRemoval.RemoveConfiguredObjects()
        message = "Broadcasted removal request for all configured objects."
    end

    if source == 0 then
        print(message)
    else
        TriggerClientEvent("chat:addMessage", source, { args = {"^2[POGGY_UTIL]", message} })
    end
end, false)

-- Register admin command to manually cleanup dead entities
RegisterCommand("cleandead", function(source, args, rawCommand)
    if not IsPlayerAdmin(source) then
        if source > 0 then
            TriggerClientEvent("chat:addMessage", source, { args = {"^1[POGGY_UTIL]", "You don't have permission."} })
        end
        return
    end

    PoggyUtil.ObjectRemoval.CleanupDeadEntities()
    
    local message = "Broadcasted dead entity cleanup request to all clients."
    if source == 0 then
        print(message)
    else
        TriggerClientEvent("chat:addMessage", source, { args = {"^2[POGGY_UTIL]", message} })
    end
end, false)

-- Main thread to periodically remove objects
Citizen.CreateThread(function()
    while Config == nil or Config.ObjectRemoval == nil do Citizen.Wait(1000) end
    if not Config.ObjectRemoval.Enabled then return end

    PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Automatic object removal initialized. Interval: %d minutes", Config.ObjectRemoval.IntervalMinutes)
    Citizen.Wait(30000)

    local intervalMs = Config.ObjectRemoval.IntervalMinutes * 60 * 1000
    while true do
        PoggyUtil.ObjectRemoval.RemoveConfiguredObjects()
        PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Periodic cleanup broadcast sent to all clients.")
        Citizen.Wait(intervalMs)
    end
end)

-- Thread for periodic dead entity cleanup
Citizen.CreateThread(function()
    while Config == nil or Config.ObjectRemoval == nil do Citizen.Wait(1000) end
    
    local deadConfig = Config.ObjectRemoval.DeadEntityCleanup
    if not Config.ObjectRemoval.Enabled or not deadConfig or not deadConfig.Enabled then 
        return 
    end

    PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Dead entity cleanup initialized. Interval: %d minutes", deadConfig.IntervalMinutes)
    
    -- Initial delay before first cleanup
    Citizen.Wait(60000)

    local intervalMs = deadConfig.IntervalMinutes * 60 * 1000
    while true do
        PoggyUtil.ObjectRemoval.CleanupDeadEntities()
        PoggyUtil.DebugServer.Info("OBJECT_REMOVAL", "Periodic dead entity cleanup broadcast sent to all clients.")
        Citizen.Wait(intervalMs)
    end
end)

PoggyUtil.DebugServer.Info("CORE", "Object Removal Utility Initialized.")