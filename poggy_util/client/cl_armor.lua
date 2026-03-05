-- File: client/cl_armor.lua
-- Description: Armor protection + durability meter + repair-kit system
--
-- Armor detection: native "armor" clothing category (0x72E6EF74), same slot used
-- by jo_libs / vorp_character / jo_clothingstore.
--
-- Durability: 20 absorbed chest/abdomen shots (configurable via Config.ArmorProtection).
-- Each 2 shots consumed drops the HUD one stage (rpg_tank_10 → rpg_tank_1 → empty).
-- When shots reach 0 the armor stops blocking.  A VORP "armor_kit" item triggers an
-- animation + progress bar and fully restores durability.

PoggyUtil = PoggyUtil or {}
PoggyUtil.Armor = PoggyUtil.Armor or {}

-- ============================================================================
-- CONSTANTS
-- ============================================================================

-- 0x72E6EF74 == joaat("armor") — confirmed in rdr3_discoveries cloth_hash_names.lua
local ARMOR_CATEGORY_HASH = 0x72E6EF74

-- PROTECTED_BONES covers BOTH bone indices AND bone IDs so either value returned
-- by GetPedLastDamageBone will match.  Source: rdr3_discoveries mp_male boneNames.
local PROTECTED_BONES = {
    -- bone INDEX values
    [1]   = "skel_pelvis(idx)",
    [130] = "SKEL_Spine_Root(idx)",
    [131] = "SKEL_Spine0(idx)",
    [132] = "skel_spine1(idx)",
    [133] = "skel_spine2(idx)",
    [134] = "SKEL_Spine3(idx)",
    [135] = "skel_spine4(idx)",
    [136] = "SKEL_Spine5(idx)",
    -- bone ID values (same bones, alternate return format)
    [56200] = "skel_pelvis(id)",
    [11569] = "SKEL_Spine_Root(id)",
    [14410] = "SKEL_Spine0(id)",
    [14411] = "skel_spine1(id)",
    [14412] = "skel_spine2(id)",
    [14413] = "SKEL_Spine3(id)",
    [14414] = "skel_spine4(id)",
    [14415] = "SKEL_Spine5(id)",
}

-- ============================================================================
-- STATE
-- ============================================================================

local armorRunning        = false
local armorShotsRemaining = nil   -- nil until server syncs us on spawn
local lastArmorWornState  = false
local isRepairing         = false
local lastNotifyTime      = 0
local armorDebugEnabled   = false

-- ============================================================================
-- LOCAL HELPERS
-- ============================================================================

local function IsWearingArmorComponent(ped)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, ARMOR_CATEGORY_HASH) == 1
end

local function IsProtectedBone(boneVal)
    return PROTECTED_BONES[boneVal] ~= nil
end

local function DBG(fmt, ...)
    if not armorDebugEnabled then return end
    print(string.format("^5[ARMOR_DEBUG]^7 " .. fmt, ...))
end

-- ============================================================================
-- NUI BRIDGE
-- ============================================================================

--- Send layout / position config once so the HTML knows where to draw things.
local function SendArmorInit()
    local cfg = Config.ArmorProtection
    SendNUIMessage({
        type        = "armorInit",
        bottom      = cfg.HUD.Bottom,
        left        = cfg.HUD.Left,
        right       = cfg.HUD.Right,
        imageWidth  = cfg.HUD.ImageWidth,
        imageHeight = cfg.HUD.ImageHeight or "auto",
        shieldSize  = cfg.HUD.ShieldSize or "35px",
        repairBottom = cfg.RepairBar and cfg.RepairBar.Bottom or "90px",
        repairWidth  = cfg.RepairBar and cfg.RepairBar.Width  or "300px",
    })
end

--- Push the current shot count to the NUI so it picks the correct tank image.
local function UpdateArmorHUD()
    if not Config.ArmorProtection.HUD.Enabled then return end
    SendNUIMessage({
        type          = "armorUpdate",
        shots         = armorShotsRemaining or Config.ArmorProtection.MaxShots,
        maxShots      = Config.ArmorProtection.MaxShots,
        shotsPerStage = Config.ArmorProtection.ShotsPerStage,
    })
end

local function SetArmorHUDVisible(visible)
    if not Config.ArmorProtection.HUD.Enabled then return end
    SendNUIMessage({ type = "armorVisible", visible = visible })
end

-- ============================================================================
-- PROTECTION LOOP
-- ============================================================================

local function AbsorbDamage(ped, prevHealth, damageTaken, boneVal)
    -- Primary restore
    SetEntityHealth(ped, prevHealth, 0)
    -- Secondary restore next frame in case the engine re-applies the damage.
    -- Guard: if shots have hit 0 by the time this fires (race with a new hit),
    -- do NOT restore — that would silently absorb damage on broken armor.
    CreateThread(function()
        Wait(0)
        if (armorShotsRemaining or 0) > 0 and GetEntityHealth(ped) < prevHealth then
            SetEntityHealth(ped, prevHealth, 0)
            DBG("  second-pass restore fired")
        end
    end)

    DBG("BLOCKED %.0f dmg | bone %d (%s) | shots_left=%d",
        damageTaken, boneVal,
        tostring(PROTECTED_BONES[boneVal] or "?"),
        armorShotsRemaining or -1)

    -- Rate-limited hit notification
    if Config.ArmorProtection.NotifyPlayer then
        local now = GetGameTimer()
        if (now - lastNotifyTime) >= Config.ArmorProtection.NotifyCooldown then
            lastNotifyTime = now
            PoggyNotification:NotifyTip(
                Config.ArmorProtection.NotifyMessage,
                Config.ArmorProtection.NotifyDuration
            )
        end
    end
end

local function RunArmorProtection()
    if armorRunning then return end
    armorRunning = true
    print("^2[ARMOR]^7 Protection thread started.")

    CreateThread(function()
        local ped        = PlayerPedId()
        local prevHealth = GetEntityHealth(ped)

        while Config.ArmorProtection.Enabled do
            Wait(0)

            ped = PlayerPedId()

            if IsPedDeadOrDying(ped) then
                prevHealth = GetEntityHealth(ped)
                Wait(500)
                goto continue
            end

            local currentHealth = GetEntityHealth(ped)

            if currentHealth < prevHealth then
                local damageTaken = prevHealth - currentHealth

                if damageTaken >= Config.ArmorProtection.MinDamageThreshold then
                    local hit, boneVal  = GetPedLastDamageBone(ped)
                    local wearingArmor  = IsWearingArmorComponent(ped)
                    local boneProtected = IsProtectedBone(boneVal)
                    local shots         = armorShotsRemaining or 0

                    DBG("HIT dmg=%.0f hit=%s bone=%d(%s) protected=%s wearing=%s shots=%d",
                        damageTaken, tostring(hit), boneVal or -1,
                        tostring(PROTECTED_BONES[boneVal] or "?"),
                        tostring(boneProtected), tostring(wearingArmor), shots)

                    if hit and boneProtected and wearingArmor and shots > 0 then
                        -- Absorb the damage
                        AbsorbDamage(ped, prevHealth, damageTaken, boneVal)
                        -- Optimistic local decrement for immediate HUD update;
                        -- server will confirm and re-sync the authoritative value.
                        armorShotsRemaining = math.max(0, shots - 1)
                        UpdateArmorHUD()
                        TriggerServerEvent("poggy_util:armor:onHit")
                        goto continue

                    elseif hit and boneProtected and wearingArmor and shots == 0 then
                        DBG("  PASS-THROUGH: armor broken (0 shots remaining)")
                    elseif armorDebugEnabled then
                        if not hit then
                            DBG("  PASS-THROUGH: hit=false")
                        elseif not boneProtected then
                            DBG("  PASS-THROUGH: bone %d not in protected set", boneVal)
                        elseif not wearingArmor then
                            DBG("  PASS-THROUGH: armor clothing category not detected")
                        end
                    end
                end

                prevHealth = currentHealth
            else
                prevHealth = currentHealth
            end

            ::continue::
        end

        armorRunning = false
        print("^1[ARMOR]^7 Protection thread stopped.")
    end)
end

-- ============================================================================
-- ARMOR WEARING STATE WATCHER
-- Slow-poll (1 s) to show/hide the HUD icon when armor is equipped/removed.
-- ============================================================================

local function RunArmorWatcher()
    CreateThread(function()
        Wait(3500) -- let framework + NUI settle first
        while Config.ArmorProtection.Enabled do
            Wait(1000)
            local ped     = PlayerPedId()
            local wearing = not IsPedDeadOrDying(ped) and IsWearingArmorComponent(ped)
            if wearing ~= lastArmorWornState then
                lastArmorWornState = wearing
                SetArmorHUDVisible(wearing)
                if wearing then UpdateArmorHUD() end
                DBG("Armor worn state → %s", tostring(wearing))
            end
        end
    end)
end

-- ============================================================================
-- REPAIR KIT — CLIENT SIDE
-- Server validates the item exists and durability < max, then fires kitStart.
-- ============================================================================

--- Animation scenario reused from poggy_trashbins — looks like working on something.
local REPAIR_SCENARIO = joaat("WORLD_HUMAN_CLEAN_TABLE")

RegisterNetEvent("poggy_util:armor:kitStart")
AddEventHandler("poggy_util:armor:kitStart", function()
    if isRepairing then
        PoggyNotification:NotifyTip("Already repairing armor.", 3000)
        return
    end

    local ped = PlayerPedId()
    if not IsWearingArmorComponent(ped) then
        PoggyNotification:NotifyTip("You are not wearing any armor.", 3000)
        TriggerServerEvent("poggy_util:armor:repairCancel")
        return
    end

    isRepairing = true
    local repairTime = Config.ArmorProtection.RepairTime

    -- Start the working animation (same pattern as poggy_trashbins search)
    ClearPedTasks(ped)
    TaskStartScenarioInPlace(ped, REPAIR_SCENARIO, -1)

    -- Show NUI progress bar
    SendNUIMessage({
        type     = "armorRepairStart",
        duration = repairTime,
        label    = "Repairing Armor...",
    })

    CreateThread(function()
        -- Stop animation slightly before bar completes so idle→finish looks smooth
        local cancelAt = math.max(repairTime - 500, 0)
        Wait(cancelAt)
        ClearPedTasks(PlayerPedId())
        Wait(repairTime - cancelAt)

        -- Finish up
        SendNUIMessage({ type = "armorRepairEnd" })
        TriggerServerEvent("poggy_util:armor:repairComplete")
        isRepairing = false
    end)
end)

RegisterNetEvent("poggy_util:armor:kitDenied")
AddEventHandler("poggy_util:armor:kitDenied", function(reason)
    if reason == "already_full" then
        PoggyNotification:NotifyTip("Your armor is already in perfect condition.", 3500)
    end
end)

-- Server authoritatively syncs durability (after hit, after repair, on join)
RegisterNetEvent("poggy_util:armor:durabilitySync")
AddEventHandler("poggy_util:armor:durabilitySync", function(shots)
    armorShotsRemaining = shots
    UpdateArmorHUD()
    DBG("Durability synced: %d / %d", shots, Config.ArmorProtection.MaxShots)
    if shots == 0 then
        PoggyNotification:NotifyTip(
            "~r~Your armor is broken! Use an armor kit to repair it.",
            5000
        )
    end
end)

-- ============================================================================
-- DEBUG COMMANDS  (no config required — always available)
-- ============================================================================

RegisterCommand("armordebug", function()
    armorDebugEnabled = not armorDebugEnabled
    print(string.format("^3[ARMOR_DEBUG]^7 %s",
        armorDebugEnabled and "^2ENABLED^7" or "^1DISABLED^7"))
end, false)

-- ============================================================================
-- MOVE ARMOR HUD COMMAND
-- ============================================================================

local armorMoveActive = false

RegisterCommand("movearmor", function()
    if not Config.ArmorProtection or not Config.ArmorProtection.Enabled then return end
    if armorMoveActive then return end
    armorMoveActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "armorMoveMode", enabled = true })
end, false)

-- NUI callback: player finished dragging → server saves position
RegisterNUICallback("armorPositionSave", function(data, cb)
    if data and data.top and data.left then
        TriggerServerEvent("poggy_util:armor:saveHudPosition", data.top, data.left)
    end
    cb({ ok = true })
end)

-- NUI callback: move mode exited (Escape or overlay click)
RegisterNUICallback("armorMoveExit", function(data, cb)
    armorMoveActive = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- Server sends back the saved HUD position from DB
RegisterNetEvent("poggy_util:armor:hudPositionLoad")
AddEventHandler("poggy_util:armor:hudPositionLoad", function(top, left)
    SendNUIMessage({ type = "armorPositionLoad", top = top, left = left })
end)

RegisterCommand("armorstatus", function()
    local ped = PlayerPedId()
    print(string.format(
        "^3[ARMOR_STATUS]^7  ped=%d  health=%d  wearing=%s  shots=%s/%d  repairing=%s",
        ped,
        GetEntityHealth(ped),
        tostring(IsWearingArmorComponent(ped)),
        tostring(armorShotsRemaining),
        Config.ArmorProtection.MaxShots,
        tostring(isRepairing)
    ))
end, false)

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function PoggyUtil.Armor.IsWearing()
    return IsWearingArmorComponent(PlayerPedId())
end

function PoggyUtil.Armor.GetShots()
    return armorShotsRemaining or Config.ArmorProtection.MaxShots
end

function PoggyUtil.Armor.IsBroken()
    return (armorShotsRemaining or Config.ArmorProtection.MaxShots) <= 0
end

exports("ArmorIsWearing",  PoggyUtil.Armor.IsWearing)
exports("ArmorGetShots",   PoggyUtil.Armor.GetShots)
exports("ArmorIsBroken",   PoggyUtil.Armor.IsBroken)

--- ArmorShouldBlockBleeding()
-- Returns true when the player is wearing armor, durability > 0, AND the last
-- damage bone is inside the protected torso set.  Designed to be polled from
-- mega_doctorjob's EVENT_NETWORK_DAMAGE_ENTITY handler so that bleeding is not
-- applied to torso shots until the armor is fully depleted.
exports("ArmorShouldBlockBleeding", function()
    local ped = PlayerPedId()
    if not IsWearingArmorComponent(ped) then return false end
    if (armorShotsRemaining or 0) <= 0 then return false end
    local hit, boneVal = GetPedLastDamageBone(ped)
    return hit == true and IsProtectedBone(boneVal)
end)

-- ============================================================================
-- STARTUP
-- ============================================================================

local function TryStart()
    if not Config.ArmorProtection or not Config.ArmorProtection.Enabled then
        print("^3[ARMOR]^7 Disabled in config — not starting.")
        return
    end
    SendArmorInit()
    TriggerServerEvent("poggy_util:armor:requestDurability")
    TriggerServerEvent("poggy_util:armor:requestHudPosition")
    RunArmorProtection()
    RunArmorWatcher()
end

AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CreateThread(function()
        Wait(2000)
        TryStart()
    end)
end)

if GetResourceState(GetCurrentResourceName()) == "started" then
    CreateThread(function()
        Wait(2000)
        TryStart()
    end)
end
