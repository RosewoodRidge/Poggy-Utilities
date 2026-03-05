-- File: cl_unstuck.lua
-- Description: Unstuck command - teleports player to nearest road after a configurable delay
-- Player must remain stationary during the countdown or it cancels

local isUnstucking = false

--- Get the nearest road position to the player
--- Uses RDR3 PATHFIND natives with multiple fallbacks
---@param playerCoords vector3
---@return vector3|nil roadCoords
local function GetNearestRoadCoords(playerCoords)
    local x, y, z = playerCoords.x, playerCoords.y, playerCoords.z

    -- Primary: GET_CLOSEST_VEHICLE_NODE_WITH_HEADING (RDR3 hash 0x23CFFD4CCB243354)
    -- Params: x, y, z, nodeType, p6, p7 -> returns: bool, Vector3, float
    local found, nodePos, heading = GetClosestVehicleNodeWithHeading(x, y, z, 1, 3.0, 0)
    if found then
        return vector3(nodePos.x, nodePos.y, nodePos.z)
    end

    -- Fallback 1: GET_CLOSEST_ROAD (RDR3 hash 0x132F52BBA570FE92)
    -- Params: x, y, z, p3, p4, p10 -> returns: bool, Vector3, Vector3, Any, Any, float
    local roadFound, roadPos1, roadPos2 = GetClosestRoad(x, y, z, 50.0, 1, false)
    if roadFound then
        return vector3(roadPos1.x, roadPos1.y, roadPos1.z)
    end

    -- Fallback 2: GET_SAFE_COORD_FOR_PED (RDR3 hash 0xB61C8E878A4199CA)
    -- Params: x, y, z, onGround, flags -> returns: bool, Vector3
    local success, safePos = GetSafeCoordForPed(x, y, z, true, 16)
    if success then
        return vector3(safePos.x, safePos.y, safePos.z)
    end

    return nil
end

--- Execute the unstuck process
local function DoUnstuck()
    if isUnstucking then
        PoggyFramework.Notify("You are already being unstuck!", 3000)
        return
    end

    local ped = PlayerPedId()
    if IsPedDeadOrDying(ped) then
        PoggyFramework.Notify("You cannot use unstuck while dead.", 3000)
        return
    end

    isUnstucking = true
    local delay = Config.Unstuck.DelaySeconds
    local startPos = GetEntityCoords(ped)
    local moveTolerance = Config.Unstuck.MoveTolerance

    PoggyFramework.Notify("Unstuck in " .. delay .. " seconds. Do not move!", delay * 1000)

    -- Freeze player in place
    FreezeEntityPosition(ped, true)

    -- Countdown loop - check each second
    local cancelled = false
    for i = delay, 1, -1 do
        Wait(1000)

        ped = PlayerPedId()
        local currentPos = GetEntityCoords(ped)
        local dist = #(currentPos - startPos)

        -- Check if player somehow moved (e.g. pushed, damaged, etc.)
        if dist > moveTolerance then
            cancelled = true
            break
        end

        -- Check if player died during countdown
        if IsPedDeadOrDying(ped) then
            cancelled = true
            break
        end
    end

    if cancelled then
        FreezeEntityPosition(ped, false)
        isUnstucking = false
        PoggyFramework.Notify("Unstuck cancelled - you moved or died.", 3000)
        return
    end

    -- Find nearest road
    local playerCoords = GetEntityCoords(ped)
    local roadCoords = GetNearestRoadCoords(playerCoords)

    if roadCoords then
        -- Teleport player to road
        SetEntityCoords(ped, roadCoords.x, roadCoords.y, roadCoords.z, false, false, false, false)
        -- Small wait to let the world load
        Wait(500)
        -- Place on ground properly
        PlaceEntityOnGroundProperly(ped)
        FreezeEntityPosition(ped, false)
        PoggyFramework.Notify("You have been teleported to the nearest road.", 5000)
    else
        FreezeEntityPosition(ped, false)
        PoggyFramework.Notify("Could not find a nearby road. Try again in a different spot.", 5000)
    end

    isUnstucking = false
end

-- Register command
RegisterCommand(Config.Unstuck.Command, function()
    if not Config.Unstuck.Enabled then return end
    DoUnstuck()
end, false)

-- Also allow trigger via event (for keybinds or other scripts)
RegisterNetEvent('poggy_util:unstuck')
AddEventHandler('poggy_util:unstuck', function()
    if not Config.Unstuck.Enabled then return end
    DoUnstuck()
end)
