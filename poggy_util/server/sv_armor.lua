-- File: server/sv_armor.lua
-- Description: Server-side armor durability tracking and armor_kit item handler.
--
-- All durability is stored in playerShots[serverId] for the session.
-- The client always receives an authoritative "durabilitySync" event so its
-- optimistic local counter stays in lockstep with the server.

-- ============================================================================
-- SESSION STORE
-- ============================================================================

local playerShots = {}   -- [serverId] = int (shots remaining)

local function MaxShots()
    return Config.ArmorProtection.MaxShots
end

local function GetShots(src)
    if playerShots[src] == nil then
        playerShots[src] = MaxShots()
    end
    return playerShots[src]
end

local function SetShots(src, n)
    playerShots[src] = math.max(0, math.min(MaxShots(), n))
    TriggerClientEvent("poggy_util:armor:durabilitySync", src, playerShots[src])
end

-- ============================================================================
-- NETWORK EVENTS
-- ============================================================================

-- Client requests current durability (on spawn / resource restart)
RegisterServerEvent("poggy_util:armor:requestDurability")
AddEventHandler("poggy_util:armor:requestDurability", function()
    local src = source
    TriggerClientEvent("poggy_util:armor:durabilitySync", src, GetShots(src))
end)

-- Client absorbed a shot — decrement and confirm
RegisterServerEvent("poggy_util:armor:onHit")
AddEventHandler("poggy_util:armor:onHit", function()
    local src    = source
    local shots  = GetShots(src)
    if shots > 0 then
        SetShots(src, shots - 1)
    end
end)

-- Client finished the repair animation — restore durability and consume item
RegisterServerEvent("poggy_util:armor:repairComplete")
AddEventHandler("poggy_util:armor:repairComplete", function()
    local src   = source
    local shots = GetShots(src)

    if shots >= MaxShots() then
        -- Edge-case: somehow already full (client should have caught this)
        TriggerClientEvent("poggy_util:armor:kitDenied", src, "already_full")
        return
    end

    -- Consume one armor_kit from VORP inventory
    pcall(function()
        exports.vorp_inventory:subItem(src, Config.ArmorProtection.RepairKitItem, 1)
    end)

    -- Restore to full
    SetShots(src, MaxShots())
    print(string.format("^2[ARMOR]^7 Player %d repaired armor. Durability restored to %d.", src, MaxShots()))
end)

-- Client cancelled the repair before it finished (e.g., moved away)
RegisterServerEvent("poggy_util:armor:repairCancel")
AddEventHandler("poggy_util:armor:repairCancel", function()
    -- Nothing to undo; item was not yet subtracted
end)

-- ============================================================================
-- VORP INVENTORY — USABLE ITEM
-- ============================================================================

local function RegisterRepairKit()
    local itemName = Config.ArmorProtection.RepairKitItem
    if not itemName or itemName == "" then
        print("^3[ARMOR]^7 No RepairKitItem configured — skipping registerUsableItem.")
        return
    end

    local ok, err = pcall(function()
        exports.vorp_inventory:registerUsableItem(itemName, function(data)
            local src    = data.source
            local shots  = GetShots(src)

            if shots >= MaxShots() then
                TriggerClientEvent("poggy_util:armor:kitDenied", src, "already_full")
                return
            end

            -- Tell the client to start the repair animation + progress bar.
            -- The item is only consumed after the animation completes (repairComplete event).
            TriggerClientEvent("poggy_util:armor:kitStart", src)
        end)
    end)

    if ok then
        print(string.format("^2[ARMOR]^7 Registered usable item '%s'.", itemName))
    else
        print(string.format("^1[ARMOR]^7 Failed to register '%s': %s", itemName, tostring(err)))
    end
end

-- Register immediately on load and again when the resource restarts (vorp_inventory
-- may not be ready at first load, so we register on both events).
AddEventHandler("onServerResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() or resourceName == "vorp_inventory" then
        Citizen.Wait(500)
        RegisterRepairKit()
    end
end)

RegisterRepairKit()   -- attempt at load; safe to call multiple times

-- ============================================================================
-- HUD POSITION  — save/load per character
-- ============================================================================

local function GetCharIdentifier(src)
    local charId = nil
    pcall(function()
        local VORPCore = exports.vorp_core:GetCore()
        if not VORPCore then return end
        local user = VORPCore.getUser(src)
        if not user then return end
        local char = user.getUsedCharacter()
        if char then
            charId = char.charidentifier
        end
    end)
    return charId
end

RegisterServerEvent("poggy_util:armor:saveHudPosition")
AddEventHandler("poggy_util:armor:saveHudPosition", function(top, left)
    local src    = source
    if type(top) ~= "string" or type(left) ~= "string" then return end
    -- Sanitise: only allow CSS pixel values like "123px"
    if not top:match("^%-?%d+px$") or not left:match("^%-?%d+px$") then return end
    local charId = GetCharIdentifier(src)
    if not charId then return end
    exports.oxmysql:execute(
        "UPDATE `characters` SET `armor_hud_pos` = ? WHERE `charidentifier` = ?",
        { top .. "," .. left, charId }
    )
end)

RegisterServerEvent("poggy_util:armor:requestHudPosition")
AddEventHandler("poggy_util:armor:requestHudPosition", function()
    local src    = source
    local charId = GetCharIdentifier(src)
    if not charId then return end
    exports.oxmysql:scalar(
        "SELECT `armor_hud_pos` FROM `characters` WHERE `charidentifier` = ?",
        { charId },
        function(value)
            if not value or value == "" then return end
            local top, left = string.match(tostring(value), "^([^,]+),(.+)$")
            if top and left then
                TriggerClientEvent("poggy_util:armor:hudPositionLoad", src, top, left)
            end
        end
    )
end)

-- ============================================================================
-- CLEANUP
-- ============================================================================

AddEventHandler("playerDropped", function()
    playerShots[source] = nil
end)
