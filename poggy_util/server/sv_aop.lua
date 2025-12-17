PoggyUtil = PoggyUtil or {}
PoggyUtil.AOP = {}

-- Wait for dependencies
Citizen.CreateThread(function()
    while PoggyUtil.DebugServer == nil or Config == nil or Config.AOP == nil do
        Citizen.Wait(100)
    end
    
    if not Config.AOP.Enabled then
        PoggyUtil.DebugServer.Info("AOP", "Area of Play system is disabled via config.")
        return
    end
    
    PoggyUtil.DebugServer.Info("AOP", "Area of Play system initialized.")
    PoggyUtil.DebugServer.Info("AOP", "Configured zones: %d", #Config.AOP.Zones)
end)

local GlobalAOP = "Unknown"

-- Thread to calculate the most populated zone
Citizen.CreateThread(function()
    -- Wait for DebugServer to be available
    while PoggyUtil.DebugServer == nil do
        Citizen.Wait(1000)
    end

    while true do
        Citizen.Wait(5000) -- Check every 5 seconds
        
        if Config and Config.AOP and Config.AOP.Enabled and Config.AOP.Zones then
            local zoneCounts = {}
            local maxCount = 0
            local bestZone = nil
            
            local players = GetPlayers()
            
            -- Debug: Start calculation cycle
            PoggyUtil.DebugServer.Trace("AOP", "--- Calculating Global AOP (Players: %d) ---", #players)

            for _, src in ipairs(players) do
                local ped = GetPlayerPed(src)
                if DoesEntityExist(ped) then
                    local pCoords = GetEntityCoords(ped)
                    
                    -- Find zone for this player
                    local pZone = nil
                    local pDist = Config.AOP.SearchRadius
                    
                    for _, zone in ipairs(Config.AOP.Zones) do
                        local dist = #(pCoords - zone.coords)
                        if dist < pDist then
                            pZone = zone.name
                            pDist = dist
                        end
                    end
                    
                    if pZone then
                        zoneCounts[pZone] = (zoneCounts[pZone] or 0) + 1
                        if zoneCounts[pZone] > maxCount then
                            maxCount = zoneCounts[pZone]
                            bestZone = pZone
                        end
                        PoggyUtil.DebugServer.Trace("AOP", "Player %s found in %s (%.1fm)", src, pZone, pDist)
                    else
                        PoggyUtil.DebugServer.Trace("AOP", "Player %s is not in any zone", src)
                    end
                else
                    PoggyUtil.DebugServer.Warning("AOP", "Player %s ped not found", src)
                end
            end
            
            if bestZone then
                GlobalAOP = bestZone
                PoggyUtil.DebugServer.Info("AOP", "Global AOP set to: %s (Count: %d)", GlobalAOP, maxCount)
            else
                GlobalAOP = "Unknown"
                PoggyUtil.DebugServer.Info("AOP", "No populated zones found. Global AOP is Unknown.")
            end
        end
    end
end)

--[[
    Calculate the nearest zone to player coordinates
    @param vector3 playerCoords - The player's current coordinates
    @returns table|nil - Zone info {name, distance} or nil if none within radius
]]
function PoggyUtil.AOP.GetNearestZone(playerCoords)
    if not Config.AOP.Enabled or not Config.AOP.Zones then
        return nil
    end
    
    local closestZone = nil
    local closestDistance = Config.AOP.SearchRadius
    
    for _, zone in ipairs(Config.AOP.Zones) do
        local distance = #(playerCoords - zone.coords)
        
        if distance < closestDistance then
            closestZone = zone
            closestDistance = distance
        end
    end
    
    if closestZone then
        PoggyUtil.DebugServer.Trace("AOP", "Nearest zone: %s (%.1fm away)", closestZone.name, closestDistance)
        return {
            name = closestZone.name,
            distance = closestDistance
        }
    end
    
    return nil
end

-- Handle client request for zone update
RegisterNetEvent("poggy_util:requestAOPUpdate")
AddEventHandler("poggy_util:requestAOPUpdate", function()
    local source = source
    
    if not Config.AOP.Enabled then
        return
    end
    
    -- Get player count
    local playerCount = #GetPlayers()
    
    -- Send the global AOP instead of local player zone
    TriggerClientEvent("poggy_util:updateAOP", source, GlobalAOP, playerCount)
    if PoggyUtil.DebugServer then
        PoggyUtil.DebugServer.Trace("AOP", "Sent global AOP update to player %d: %s", source, GlobalAOP)
    end
end)

Citizen.CreateThread(function()
    while PoggyUtil.DebugServer == nil do Citizen.Wait(100) end
    PoggyUtil.DebugServer.Info("CORE", "AOP Server Script Loaded.")
end)
