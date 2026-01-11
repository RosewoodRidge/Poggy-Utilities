-- File: server/sv_player.lua
-- Description: Player utility functions for poggy_util
-- Now framework-agnostic - uses PoggyFramework for all player data

PoggyUtil = PoggyUtil or {}
PoggyUtil.Player = {}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

Citizen.CreateThread(function()
    -- Wait for PoggyFramework to be available
    local attempts = 0
    while not PoggyFramework and attempts < 50 do
        Citizen.Wait(100)
        attempts = attempts + 1
    end
    
    if not PoggyFramework then
        print("^1[POGGY_UTIL_PLAYER] ERROR: PoggyFramework not loaded!^7")
        return
    end
    
    -- Initialize framework
    PoggyFramework.Initialize()
    PoggyFramework.WaitUntilReady()
    
    local fwType = PoggyFramework.GetType() or "unknown"
    if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
        PoggyUtil.DebugServer.Info("PLAYER", "Framework initialized: %s", fwType)
    else
        print("^2[POGGY_UTIL_PLAYER]^7 Framework initialized: " .. fwType)
    end
end)

-- ============================================================================
-- PLAYER FUNCTIONS (using PoggyFramework)
-- ============================================================================

-- Function to get character information for a player (framework-agnostic)
function PoggyUtil.Player.GetCharacterInfo(source)
    -- Use the new framework abstraction
    if PoggyFramework and PoggyFramework.IsReady then
        local charInfo = exports['poggy_util']:GetCharacterInfo(source)
        if charInfo then
            return charInfo
        end
    end
    
    -- Fallback: Try to get from framework directly
    local src = tonumber(source)
    if not src or src <= 0 then
        if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Error then
            PoggyUtil.DebugServer.Error("PLAYER", "GetCharacterInfo: Invalid source provided: %s", tostring(source))
        end
        return nil
    end
    
    -- Try framework-specific methods
    local fwType = PoggyFramework and PoggyFramework.GetType() or nil
    local core = PoggyFramework and PoggyFramework.GetCore() or nil
    
    if fwType == 'vorp' then
        -- Use VORP exports directly with new API
        local VORPCore = nil
        local success = pcall(function()
            VORPCore = exports.vorp_core:vorpAPI()
        end)
        
        -- Fallback to old API if new one doesn't exist
        if not success or not VORPCore then
            success = pcall(function()
                VORPCore = exports.vorp_core:GetCore()
            end)
        end
        
        if success and VORPCore then
            local user = VORPCore.getUser(src)
            if user then
                local character = user.getUsedCharacter
                if character then
                    return {
                        charId = character.charIdentifier,
                        identifier = character.identifier,
                        firstname = character.firstname,
                        lastname = character.lastname,
                        job = character.job,
                        jobLabel = character.job,
                        jobGrade = character.jobGrade,
                        jobGradeName = tostring(character.jobGrade),
                        group = character.group
                    }
                end
            end
        end
    elseif fwType == 'rsg' and core then
        local Player = core.Functions.GetPlayer(src)
        if Player then
            local pd = Player.PlayerData
            return {
                charId = pd.citizenid,
                identifier = pd.license,
                firstname = pd.charinfo and pd.charinfo.firstname or "Unknown",
                lastname = pd.charinfo and pd.charinfo.lastname or "Unknown",
                job = pd.job and pd.job.name or "unemployed",
                jobLabel = pd.job and pd.job.label or "Unemployed",
                jobGrade = pd.job and pd.job.grade and pd.job.grade.level or 0,
                jobGradeName = pd.job and pd.job.grade and pd.job.grade.name or "None"
            }
        end
    end
    
    if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Warning then
        PoggyUtil.DebugServer.Warning("PLAYER", "GetCharacterInfo: Could not get character for source %s", src)
    end
    return nil
end

-- ============================================================================
-- GOVERNMENT STIPEND SYSTEM (framework-agnostic)
-- ============================================================================

Citizen.CreateThread(function()
    -- Wait for dependencies
    local waitAttempts = 0
    while (not PoggyFramework or not PoggyFramework.IsReady or not PoggyFramework.IsReady()) and waitAttempts < 100 do
        Citizen.Wait(500)
        waitAttempts = waitAttempts + 1
    end
    
    while not Config or not Config.Stipend do 
        Citizen.Wait(1000) 
    end

    if not Config.Stipend.Enabled then return end

    if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
        PoggyUtil.DebugServer.Info("STIPEND", "Initializing Government Stipend System...")
    end

    -- Get the correct table name based on framework
    local fwType = PoggyFramework.GetType()
    local tableName = "characters" -- Default for VORP/RedemRP
    local charIdColumn = "charIdentifier"
    local jobColumn = "job"
    
    if fwType == 'rsg' or fwType == 'qbcore' then
        tableName = "players"
        charIdColumn = "citizenid"
        jobColumn = "job" -- This is JSON in RSG/QB
    end

    -- 1. Ensure 'created_at' column exists
    local checkQuery = string.format(
        "SELECT count(*) as count FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = '%s' AND column_name = 'created_at'",
        tableName
    )
    
    local columnExists = MySQL.scalar.await(checkQuery, {})
    
    if columnExists == 0 then
        if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
            PoggyUtil.DebugServer.Info("STIPEND", "Adding 'created_at' column to %s table with legacy date: %s", tableName, Config.Stipend.LegacyDate)
        end
        
        -- Add column with default value for EXISTING records
        local alterQuery = string.format("ALTER TABLE %s ADD COLUMN created_at DATETIME DEFAULT '%s'", tableName, Config.Stipend.LegacyDate)
        MySQL.execute.await(alterQuery, {})
        
        -- Update default to CURRENT_TIMESTAMP for NEW records
        local modifyQuery = string.format("ALTER TABLE %s MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP", tableName)
        MySQL.execute.await(modifyQuery, {})
        
        if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
            PoggyUtil.DebugServer.Info("STIPEND", "Database schema updated successfully.")
        end
    else
        if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
            PoggyUtil.DebugServer.Info("STIPEND", "Database schema check passed.")
        end
    end

    -- 2. Stipend Loop
    local intervalMs = Config.Stipend.IntervalMinutes * 60 * 1000
    
    while true do
        Citizen.Wait(intervalMs)
        
        local players = GetPlayers()
        if #players > 0 then
            if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
                PoggyUtil.DebugServer.Info("STIPEND", "Processing stipend for %d players...", #players)
            end
            
            for _, srcStr in ipairs(players) do
                local src = tonumber(srcStr)
                local charInfo = PoggyUtil.Player.GetCharacterInfo(src)
                
                if charInfo then
                    -- Check if unemployed (case-insensitive)
                    local playerJob = charInfo.job or ""
                    if string.lower(playerJob) == string.lower(Config.Stipend.UnemployedJobName) then
                        
                        -- Get tenure in days from database
                        local diffQuery = string.format(
                            "SELECT TIMESTAMPDIFF(DAY, created_at, NOW()) as days FROM %s WHERE %s = ?",
                            tableName, charIdColumn
                        )
                        local days = MySQL.scalar.await(diffQuery, {charInfo.charId})
                        
                        if days and days >= Config.Stipend.MinimumTenureDays then
                            -- Calculate Pay
                            local extraIncrements = math.floor((days - Config.Stipend.MinimumTenureDays) / Config.Stipend.IncreaseIntervalDays)
                            if extraIncrements < 0 then extraIncrements = 0 end
                            
                            local totalPay = Config.Stipend.BasePay + (extraIncrements * Config.Stipend.IncreaseAmount)
                            
                            -- Pay Player (framework-specific)
                            local paid = false
                            local core = PoggyFramework.GetCore()
                            
                            if fwType == 'vorp' then
                                -- Use VORP exports directly with new API
                                local VORPCore = nil
                                local success = pcall(function()
                                    VORPCore = exports.vorp_core:vorpAPI()
                                end)
                                
                                -- Fallback to old API if new one doesn't exist
                                if not success or not VORPCore then
                                    success = pcall(function()
                                        VORPCore = exports.vorp_core:GetCore()
                                    end)
                                end
                                
                                if success and VORPCore then
                                    local user = VORPCore.getUser(src)
                                    if user then
                                        local char = user.getUsedCharacter
                                        if char then
                                            char.addCurrency(0, totalPay)
                                            paid = true
                                        end
                                    end
                                end
                            elseif fwType == 'rsg' and core then
                                local Player = core.Functions.GetPlayer(src)
                                if Player then
                                    Player.Functions.AddMoney('cash', totalPay)
                                    paid = true
                                end
                            elseif fwType == 'qbcore' and core then
                                local Player = core.Functions.GetPlayer(src)
                                if Player then
                                    Player.Functions.AddMoney('cash', totalPay)
                                    paid = true
                                end
                            end
                            
                            if paid then
                                -- Notify using poggy_util notifications
                                local msg = string.format("Government Stipend: $%.2f", totalPay)
                                TriggerClientEvent("poggy:TipRight", src, msg, 4000)
                                
                                if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Info then
                                    PoggyUtil.DebugServer.Info("STIPEND", "Paid %s (ID: %d, Days: %d) $%.2f", 
                                        charInfo.firstname or "Unknown", src, days, totalPay)
                                end
                            end
                        else
                            if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Trace then
                                PoggyUtil.DebugServer.Trace("STIPEND", "Player %s not eligible (Days: %s < %s)", 
                                    charInfo.firstname or "Unknown", tostring(days), Config.Stipend.MinimumTenureDays)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Music Preference now stored client-side via KVP (see cl_music.lua)
