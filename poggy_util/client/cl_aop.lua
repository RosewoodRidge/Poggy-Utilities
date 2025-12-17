PoggyUtil = PoggyUtil or {}
PoggyUtil.AOP = {}

local aopVisible = true
local currentZoneName = nil

-- Wait for config to load
Citizen.CreateThread(function()
    while Config == nil or Config.AOP == nil do
        Citizen.Wait(100)
    end
    
    if not Config.AOP.Enabled then
        -- PoggyUtil.DebugClient.Info("AOP", "Area of Play system is disabled via config.")
        return
    end
    
    -- PoggyUtil.DebugClient.Info("AOP", "Area of Play system initialized.")
    
    -- Initial zone check
    Citizen.Wait(2000)
    TriggerServerEvent("poggy_util:requestAOPUpdate")
    
    -- Automatic update loop
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.AOP.UpdateInterval * 1000)
            
            if aopVisible then
                TriggerServerEvent("poggy_util:requestAOPUpdate")
            end
        end
    end)
end)

-- Receive zone update from server
RegisterNetEvent("poggy_util:updateAOP")
AddEventHandler("poggy_util:updateAOP", function(zoneName, playerCount)
    currentZoneName = zoneName
    
    if aopVisible then
        if zoneName then
            -- PoggyUtil.DebugClient.Info("AOP", "Displaying zone: %s", zoneName)
            SendNUIMessage({
                type = "updateAOP",
                visible = true,
                zoneName = zoneName,
                playerCount = playerCount
            })
        else
            -- PoggyUtil.DebugClient.Info("AOP", "No zone nearby, hiding AOP")
            SendNUIMessage({
                type = "updateAOP",
                visible = false
            })
        end
    end
end)

-- Toggle AOP visibility
RegisterCommand("aop", function()
    aopVisible = not aopVisible
    
    if aopVisible then
        -- Re-request current zone when showing
        TriggerServerEvent("poggy_util:requestAOPUpdate")
        TriggerEvent("vorp:TipRight", "Area of Play display enabled", 3000)
    else
        -- Hide AOP
        SendNUIMessage({
            type = "updateAOP",
            visible = false
        })
        TriggerEvent("vorp:TipRight", "Area of Play display disabled", 3000)
    end
    
    -- PoggyUtil.DebugClient.Info("AOP", "AOP visibility toggled: %s", tostring(aopVisible))
end, false)

-- PoggyUtil.DebugClient.Info("CORE", "AOP Client Script Loaded.")
