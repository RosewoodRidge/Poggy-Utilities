-- File: server/sv_framework.lua
-- Description: Server-side framework abstraction for poggy_util
-- Provides unified player/character data access across all frameworks

-- Ensure PoggyFramework exists (should be defined in shared/sh_framework.lua)
if not PoggyFramework then
    PoggyFramework = {}
    print("^3[POGGY-FRAMEWORK-SV]^7 Warning: PoggyFramework not found from shared scripts, creating empty table")
end

-- ============================================================================
-- DEBUG HELPER
-- ============================================================================
local function Debug(msg)
    if Config and Config.PoggyDebug and Config.PoggyDebug.Enabled and Config.PoggyDebug.Categories.CORE then
        print("^3[POGGY-FRAMEWORK-SV]^7 " .. msg)
    end
end

-- ============================================================================
-- PLAYER DATA FUNCTIONS
-- ============================================================================

--- Get player/user object by source
---@param source number The player's server ID
---@return table|nil The player object or nil if not found
function PoggyFramework.GetPlayer(source)
    if not PoggyFramework.IsReady then return nil end
    if not PoggyFramework.IsReady() then return nil end
    
    local fwType = PoggyFramework.GetType()
    local core = PoggyFramework.GetCore()
    
    if fwType == 'rsg' and core then
        return core.Functions.GetPlayer(source)
    elseif fwType == 'qbcore' and core then
        return core.Functions.GetPlayer(source)
    elseif fwType == 'vorp' or fwType == 'standalone' or fwType == 'redemrp' then
        -- For VORP, standalone, and redemrp, return database-based character info
        return PoggyFramework.GetCharacterInfoFromDB(source)
    end
    
    return nil
end

--- Get character data from a player (framework-specific format)
---@param source number The player's server ID
---@return table|nil Character data table
function PoggyFramework.GetCharacter(source)
    if not PoggyFramework.IsReady() then return nil end
    
    local fwType = PoggyFramework.GetType()
    local core = PoggyFramework.GetCore()
    
    if fwType == 'rsg' and core then
        local Player = core.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData
        end
    elseif fwType == 'qbcore' and core then
        local Player = core.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData
        end
    elseif fwType == 'vorp' or fwType == 'standalone' or fwType == 'redemrp' then
        -- For VORP, standalone, and redemrp, return database-based character info
        return PoggyFramework.GetCharacterInfoFromDB(source)
    end
    
    return nil
end

--- Get normalized character info (same format across all frameworks)
---@param source number The player's server ID
---@return table|nil Normalized character info
function PoggyFramework.GetCharacterInfo(source)
    if not PoggyFramework.IsReady() then return nil end
    
    local fwType = PoggyFramework.GetType()
    local core = PoggyFramework.GetCore()
    
    if fwType == 'rsg' and core then
        local Player = core.Functions.GetPlayer(source)
        if not Player then return nil end
        
        local pd = Player.PlayerData
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
        local Player = core.Functions.GetPlayer(source)
        if not Player then return nil end
        
        local pd = Player.PlayerData
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
    elseif fwType == 'vorp' or fwType == 'standalone' or fwType == 'redemrp' then
        -- Use database-based retrieval for VORP, standalone, and redemrp
        -- This is more reliable across all VORP versions
        return PoggyFramework.GetCharacterInfoFromDB(source)
    end
    
    return nil
end

--- Get character info from database (for VORP, standalone, and redemrp mode)
---@param source number The player's server ID
---@return table|nil Normalized character info
function PoggyFramework.GetCharacterInfoFromDB(source)
    -- Get steam identifier (VORP uses steam) and license (RSG/QBCore use license)
    local steamId = GetPlayerIdentifierByType(source, 'steam')
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not steamId and not license then
        Debug("GetCharacterInfoFromDB: No identifier found for player " .. tostring(source))
        return nil
    end
    
    local result = nil
    local fwType = PoggyFramework.GetType()
    
    -- For VORP: Query using steam identifier and get the most recently logged in character
    if fwType == 'vorp' and steamId then
        Debug("GetCharacterInfoFromDB: Querying VORP characters table with steam: " .. steamId)
        result = MySQL.query.await('SELECT charidentifier, identifier, firstname, lastname, job, joblabel, jobgrade FROM characters WHERE identifier = ? ORDER BY LastLogin DESC LIMIT 1', {steamId})
        if result and result[1] then
            local char = result[1]
            Debug("GetCharacterInfoFromDB: Found VORP character - " .. (char.firstname or "") .. " " .. (char.lastname or "") .. " job: " .. (char.job or "none"))
            return {
                charId = char.charidentifier,
                identifier = char.identifier,
                firstname = char.firstname or "Unknown",
                lastname = char.lastname or "Unknown",
                job = char.job or "unemployed",
                jobLabel = char.joblabel or char.job or "Unemployed",
                jobGrade = char.jobgrade or 0,
                jobGradeName = tostring(char.jobgrade or 0),
                onDuty = nil
            }
        else
            Debug("GetCharacterInfoFromDB: No VORP character found for " .. steamId)
        end
    end
    
    -- Fallback: Try with license identifier for non-VORP or if steam lookup failed
    local identifier = license or steamId
    if not identifier then return nil end
    
    -- Try VORP characters table with license (fallback)
    result = MySQL.query.await('SELECT charidentifier, identifier, firstname, lastname, job, joblabel, jobgrade FROM characters WHERE identifier = ? ORDER BY LastLogin DESC LIMIT 1', {identifier})
    if result and result[1] then
        local char = result[1]
        return {
            charId = char.charidentifier or char.id,
            identifier = char.identifier,
            firstname = char.firstname or "Unknown",
            lastname = char.lastname or "Unknown",
            job = char.job or "unemployed",
            jobLabel = char.joblabel or char.job or "Unemployed",
            jobGrade = char.jobgrade or 0,
            jobGradeName = tostring(char.jobgrade or 0),
            onDuty = nil
        }
    end
    
    -- Try RSG/QBCore players table
    result = MySQL.query.await('SELECT * FROM players WHERE license = ? LIMIT 1', {identifier})
    if result and result[1] then
        local player = result[1]
        local charinfo = json.decode(player.charinfo or '{}')
        local jobinfo = json.decode(player.job or '{}')
        return {
            charId = player.citizenid,
            identifier = player.license,
            firstname = charinfo.firstname or "Unknown",
            lastname = charinfo.lastname or "Unknown",
            job = jobinfo.name or "unemployed",
            jobLabel = jobinfo.label or "Unemployed",
            jobGrade = jobinfo.grade and jobinfo.grade.level or 0,
            jobGradeName = jobinfo.grade and jobinfo.grade.name or "None",
            onDuty = jobinfo.onduty or false
        }
    end
    
    Debug("GetCharacterInfoFromDB: No character found in any table for " .. tostring(identifier))
    return nil
end

--- Get player's primary identifier (license)
---@param source number The player's server ID
---@return string|nil The identifier
function PoggyFramework.GetPlayerIdentifier(source)
    -- Try different identifier types
    local identifierTypes = {'license', 'steam', 'discord', 'fivem'}
    
    for _, idType in ipairs(identifierTypes) do
        local identifier = GetPlayerIdentifierByType(source, idType)
        if identifier then
            return identifier
        end
    end
    
    -- Fallback to indexed identifiers
    local numIds = GetNumPlayerIdentifiers(source)
    for i = 0, numIds - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and identifier:find('license:') then
            return identifier
        end
    end
    
    return nil
end

--- Get player's job name
---@param source number The player's server ID
---@return string|nil The job name
function PoggyFramework.GetPlayerJob(source)
    local charInfo = PoggyFramework.GetCharacterInfo(source)
    if charInfo then
        return charInfo.job
    end
    return nil
end

--- Get player's job grade
---@param source number The player's server ID
---@return number|nil The job grade level
function PoggyFramework.GetPlayerJobGrade(source)
    local charInfo = PoggyFramework.GetCharacterInfo(source)
    if charInfo then
        return charInfo.jobGrade
    end
    return nil
end

--- Check if player is on duty (for jobs that support it)
---@param source number The player's server ID
---@return boolean Whether player is on duty
function PoggyFramework.IsPlayerOnDuty(source)
    local charInfo = PoggyFramework.GetCharacterInfo(source)
    if charInfo and charInfo.onDuty ~= nil then
        return charInfo.onDuty
    end
    
    -- For VORP or frameworks without built-in duty, try external exports
    local fwType = PoggyFramework.GetType()
    
    if fwType == 'vorp' then
        -- Try vorp_police export
        local success, result = pcall(function()
            return exports.vorp_police:IsPlayerOnDuty(source)
        end)
        if success then
            return result
        end
    end
    
    -- Default to true if no duty system is available
    return true
end

--- Get all online players
---@return table Array of player source IDs
function PoggyFramework.GetPlayers()
    local players = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        table.insert(players, tonumber(playerId))
    end
    
    return players
end

--- Get player's inventory weapons
---@param source number The player's server ID
---@param callback function Callback with weapons list
function PoggyFramework.GetPlayerWeapons(source, callback)
    if not PoggyFramework.IsReady() then 
        callback({})
        return 
    end
    
    local fwType = PoggyFramework.GetType()
    
    if fwType == 'rsg' then
        -- RSG uses rsg-inventory
        local success, weapons = pcall(function()
            return exports['rsg-inventory']:GetInventory(source, 'weapons')
        end)
        if success and weapons then
            callback(weapons)
        else
            -- Fallback: get full inventory and filter weapons
            local inventory = exports['rsg-inventory']:GetInventory(source)
            local weaponsList = {}
            if inventory then
                for _, item in pairs(inventory) do
                    if item.type == 'weapon' or string.find(string.upper(item.name or ""), "WEAPON_") then
                        table.insert(weaponsList, item)
                    end
                end
            end
            callback(weaponsList)
        end
    elseif fwType == 'vorp' then
        -- VORP uses vorp_inventory
        if exports.vorp_inventory and exports.vorp_inventory.getUserInventoryWeapons then
            exports.vorp_inventory:getUserInventoryWeapons(source, function(weaponsList)
                callback(weaponsList or {})
            end)
        else
            callback({})
        end
    elseif fwType == 'qbcore' then
        -- QBCore inventory
        local success, weapons = pcall(function()
            return exports['qb-inventory']:GetInventory(source, 'weapons')
        end)
        if success and weapons then
            callback(weapons)
        else
            callback({})
        end
    else
        callback({})
    end
end

--- Send notification to player
---@param source number The player's server ID  
---@param message string The notification message
---@param duration number|nil Duration in ms (optional)
function PoggyFramework.Notify(source, message, duration)
    duration = duration or 5000
    TriggerClientEvent("poggy:TipRight", source, message, duration)
end

--- Send top notification to player
---@param source number The player's server ID
---@param title string The notification title
---@param subtitle string The notification subtitle/message
---@param duration number|nil Duration in ms (optional)
function PoggyFramework.NotifyTop(source, title, subtitle, duration)
    duration = duration or 5000
    TriggerClientEvent("poggy:ShowTopNotification", source, title, subtitle, duration)
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('GetPlayer', function(source)
    return PoggyFramework.GetPlayer(source)
end)

exports('GetCharacter', function(source)
    return PoggyFramework.GetCharacter(source)
end)

exports('GetCharacterInfo', function(source)
    return PoggyFramework.GetCharacterInfo(source)
end)

exports('GetPlayerIdentifier', function(source)
    return PoggyFramework.GetPlayerIdentifier(source)
end)

exports('GetPlayerJob', function(source)
    return PoggyFramework.GetPlayerJob(source)
end)

exports('GetPlayerJobGrade', function(source)
    return PoggyFramework.GetPlayerJobGrade(source)
end)

exports('IsPlayerOnDuty', function(source)
    return PoggyFramework.IsPlayerOnDuty(source)
end)

exports('GetPlayers', function()
    return PoggyFramework.GetPlayers()
end)

exports('GetPlayerWeapons', function(source, callback)
    PoggyFramework.GetPlayerWeapons(source, callback)
end)

exports('GetFrameworkType', function()
    return PoggyFramework.GetType()
end)

exports('IsFrameworkReady', function()
    return PoggyFramework.IsReady()
end)

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Client requests character info (for VORP/frameworks without client-side data)
RegisterServerEvent('poggy:requestCharacterInfo')
AddEventHandler('poggy:requestCharacterInfo', function()
    local source = source
    local charInfo = PoggyFramework.GetCharacterInfo(source)
    TriggerClientEvent('poggy:receiveCharacterInfo', source, charInfo)
end)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

Citizen.CreateThread(function()
    Citizen.Wait(100)
    PoggyFramework.Initialize()
    Debug("Server-side framework bridge initialized: " .. (PoggyFramework.GetType() or "unknown"))
end)

print("^2[poggy_util]^7 Server framework bridge loaded")
