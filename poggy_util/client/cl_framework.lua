-- File: client/cl_framework.lua
-- Description: Client-side framework abstraction for poggy_util
-- Provides unified player data access and framework-agnostic functions

-- ============================================================================
-- DEBUG HELPER
-- ============================================================================
local function Debug(msg)
    if Config and Config.PoggyDebug and Config.PoggyDebug.Enabled and Config.PoggyDebug.Categories.CORE then
        print("^3[POGGY-FRAMEWORK-CL]^7 " .. msg)
    end
end

-- ============================================================================
-- LOCAL PLAYER DATA
-- ============================================================================

local cachedPlayerData = nil
local cacheExpiry = 0
local CACHE_DURATION = 5000 -- 5 seconds cache

--- Get cached or fresh player data
---@return table|nil Player data
local function GetCachedPlayerData()
    local currentTime = GetGameTimer()
    
    if cachedPlayerData and currentTime < cacheExpiry then
        return cachedPlayerData
    end
    
    -- Refresh cache
    local fwType = PoggyFramework.GetType()
    local core = PoggyFramework.GetCore()
    
    if fwType == 'rsg' and core then
        cachedPlayerData = core.Functions.GetPlayerData()
    elseif fwType == 'qbcore' and core then
        cachedPlayerData = core.Functions.GetPlayerData()
    elseif fwType == 'vorp' then
        -- VORP doesn't have client-side player data getter
        -- Request from server if needed
        cachedPlayerData = nil
    end
    
    cacheExpiry = currentTime + CACHE_DURATION
    return cachedPlayerData
end

--- Clear player data cache (call on important events)
local function ClearPlayerDataCache()
    cachedPlayerData = nil
    cacheExpiry = 0
end

-- ============================================================================
-- CLIENT-SIDE PLAYER FUNCTIONS
-- ============================================================================

--- Get local player's character info (client-side)
---@return table|nil Character info
function PoggyFramework.GetLocalCharacterInfo()
    local fwType = PoggyFramework.GetType()
    local core = PoggyFramework.GetCore()
    
    if fwType == 'rsg' and core then
        local pd = core.Functions.GetPlayerData()
        if not pd then return nil end
        
        return {
            charId = pd.citizenid,
            identifier = pd.license,
            firstname = pd.charinfo and pd.charinfo.firstname or "Unknown",
            lastname = pd.charinfo and pd.charinfo.lastname or "Unknown",
            job = pd.job and pd.job.name or "unemployed",
            jobLabel = pd.job and pd.job.label or "Unemployed",
            jobGrade = pd.job and pd.job.grade and pd.job.grade.level or 0,
            jobGradeName = pd.job and pd.job.grade and pd.job.grade.name or "None",
            onDuty = pd.job and pd.job.onduty or false
        }
    elseif fwType == 'qbcore' and core then
        local pd = core.Functions.GetPlayerData()
        if not pd then return nil end
        
        return {
            charId = pd.citizenid,
            identifier = pd.license,
            firstname = pd.charinfo and pd.charinfo.firstname or "Unknown",
            lastname = pd.charinfo and pd.charinfo.lastname or "Unknown",
            job = pd.job and pd.job.name or "unemployed",
            jobLabel = pd.job and pd.job.label or "Unemployed",
            jobGrade = pd.job and pd.job.grade and pd.job.grade.level or 0,
            jobGradeName = pd.job and pd.job.grade and pd.job.grade.name or "None",
            onDuty = pd.job and pd.job.onduty or false
        }
    elseif fwType == 'vorp' then
        -- VORP requires server callback - return cached data or request
        if cachedPlayerData then
            return cachedPlayerData
        end
        
        -- Request from server (async via callback system)
        local result = nil
        local done = false
        
        TriggerServerEvent('poggy:requestCharacterInfo')
        
        RegisterNetEvent('poggy:receiveCharacterInfo')
        AddEventHandler('poggy:receiveCharacterInfo', function(charInfo)
            result = charInfo
            done = true
        end)
        
        -- Wait up to 2 seconds for response
        local timeout = GetGameTimer() + 2000
        while not done and GetGameTimer() < timeout do
            Citizen.Wait(50)
        end
        
        if result then
            cachedPlayerData = result
            cacheExpiry = GetGameTimer() + CACHE_DURATION
        end
        
        return result
    end
    
    return nil
end

--- Get local player's job name
---@return string|nil Job name
function PoggyFramework.GetLocalJob()
    local charInfo = PoggyFramework.GetLocalCharacterInfo()
    if charInfo then
        return charInfo.job
    end
    return nil
end

--- Get local player's job grade
---@return number|nil Job grade level
function PoggyFramework.GetLocalJobGrade()
    local charInfo = PoggyFramework.GetLocalCharacterInfo()
    if charInfo then
        return charInfo.jobGrade
    end
    return nil
end

--- Check if local player is on duty
---@return boolean Whether on duty
function PoggyFramework.IsLocalOnDuty()
    local charInfo = PoggyFramework.GetLocalCharacterInfo()
    if charInfo and charInfo.onDuty ~= nil then
        return charInfo.onDuty
    end
    return true -- Default to on duty
end

--- Check if local player has a specific job
---@param jobName string|table Job name or table of job names
---@return boolean Whether player has the job
function PoggyFramework.HasJob(jobName)
    local currentJob = PoggyFramework.GetLocalJob()
    if not currentJob then return false end
    
    if type(jobName) == "table" then
        for _, job in ipairs(jobName) do
            if currentJob:lower() == job:lower() then
                return true
            end
        end
        return false
    else
        return currentJob:lower() == jobName:lower()
    end
end

--- Check if local player is a law enforcement job
---@return boolean Whether player is law enforcement
function PoggyFramework.IsLawEnforcement()
    return PoggyFramework.HasJob({
        "police", "sheriff", "marshal", "lawman",
        "deputy", "ranger", "constable", "fib",
        "agent", "detective", "trooper"
    })
end

--- Get local player's full name
---@return string|nil Full name
function PoggyFramework.GetLocalFullName()
    local charInfo = PoggyFramework.GetLocalCharacterInfo()
    if charInfo then
        return charInfo.firstname .. " " .. charInfo.lastname
    end
    return nil
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Get player ped
---@return number Player ped handle
function PoggyFramework.GetPlayerPed()
    return PlayerPedId()
end

--- Get player coordinates
---@return vector3 Player coordinates
function PoggyFramework.GetPlayerCoords()
    return GetEntityCoords(PlayerPedId())
end

--- Check if player is dead
---@return boolean Whether dead
function PoggyFramework.IsPlayerDead()
    return IsEntityDead(PlayerPedId())
end

--- Check if player is in a vehicle
---@return boolean Whether in vehicle
function PoggyFramework.IsPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

--- Get current vehicle (if in one)
---@return number|nil Vehicle handle or nil
function PoggyFramework.GetCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

--- Check if player is aiming weapon
---@return boolean Whether aiming
function PoggyFramework.IsPlayerAiming()
    return IsPlayerFreeAiming(PlayerId())
end

--- Get current weapon hash
---@return number Weapon hash
function PoggyFramework.GetCurrentWeapon()
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true)
    return weaponHash
end

--- Check if player has a specific weapon
---@param weaponHash number Weapon hash
---@return boolean Whether has weapon
function PoggyFramework.HasWeapon(weaponHash)
    return HasPedGotWeapon(PlayerPedId(), weaponHash, false, false)
end

-- ============================================================================
-- NOTIFICATION SHORTCUTS (Use poggy_util notifications)
-- ============================================================================

--- Show tip notification
---@param message string Message to show
---@param duration number|nil Duration in ms
function PoggyFramework.Notify(message, duration)
    duration = duration or 5000
    
    -- Try to use poggy_util export
    local success = pcall(function()
        exports['poggy_util']:TipRight(message, duration, true)
    end)
    
    if not success then
        -- Fallback to event
        TriggerEvent("poggy:TipRight", message, duration)
    end
end

--- Show top notification
---@param title string Title
---@param subtitle string Subtitle/message
---@param duration number|nil Duration in ms
function PoggyFramework.NotifyTop(title, subtitle, duration)
    duration = duration or 5000
    
    local success = pcall(function()
        exports['poggy_util']:ShowTopNotification(title, subtitle, duration)
    end)
    
    if not success then
        TriggerEvent("poggy:ShowTopNotification", title, subtitle, duration)
    end
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Clear cache on important player data changes
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    ClearPlayerDataCache()
    Debug("Player data cache cleared (RSG player loaded)")
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    ClearPlayerDataCache()
    Debug("Player data cache cleared (QB player loaded)")
end)

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    ClearPlayerDataCache()
    Debug("Player data cache cleared (VORP character selected)")
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate')
AddEventHandler('RSGCore:Client:OnJobUpdate', function()
    ClearPlayerDataCache()
    Debug("Player data cache cleared (RSG job update)")
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function()
    ClearPlayerDataCache()
    Debug("Player data cache cleared (QB job update)")
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- Framework detection exports (client-side)
exports('GetFrameworkType', function()
    return PoggyFramework.GetType()
end)

exports('IsFrameworkReady', function()
    return PoggyFramework.IsReady()
end)

exports('GetLocalCharacterInfo', function()
    return PoggyFramework.GetLocalCharacterInfo()
end)

exports('GetLocalJob', function()
    return PoggyFramework.GetLocalJob()
end)

exports('GetLocalJobGrade', function()
    return PoggyFramework.GetLocalJobGrade()
end)

exports('IsLocalOnDuty', function()
    return PoggyFramework.IsLocalOnDuty()
end)

exports('HasJob', function(jobName)
    return PoggyFramework.HasJob(jobName)
end)

exports('IsLawEnforcement', function()
    return PoggyFramework.IsLawEnforcement()
end)

exports('GetLocalFullName', function()
    return PoggyFramework.GetLocalFullName()
end)

exports('GetPlayerPed', function()
    return PoggyFramework.GetPlayerPed()
end)

exports('GetPlayerCoords', function()
    return PoggyFramework.GetPlayerCoords()
end)

exports('IsPlayerDead', function()
    return PoggyFramework.IsPlayerDead()
end)

exports('IsPlayerInVehicle', function()
    return PoggyFramework.IsPlayerInVehicle()
end)

exports('GetCurrentVehicle', function()
    return PoggyFramework.GetCurrentVehicle()
end)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

Citizen.CreateThread(function()
    Citizen.Wait(100)
    PoggyFramework.Initialize()
    Debug("Client-side framework bridge initialized: " .. (PoggyFramework.GetType() or "unknown"))
end)

print("^2[poggy_util]^7 Client framework bridge loaded")
