-- File: shared/sh_framework.lua
-- Description: Framework-agnostic abstraction layer for poggy_util
-- Supports: VORP Core, RSG Core, QBCore, RedemRP, or standalone (no framework)
-- This file provides unified functions that work across all frameworks

PoggyFramework = PoggyFramework or {}

-- Framework detection and core object storage
local FrameworkCore = nil
local FrameworkType = nil
local FrameworkReady = false
local FrameworkDetectionComplete = false

-- Database table mappings for different frameworks
PoggyFramework.DatabaseTables = {
    vorp = {
        characters = "characters",
        users = "users",
        inventory = "inventory"
    },
    rsg = {
        players = "players",
        bans = "bans"
    },
    qbcore = {
        players = "players",
        bans = "bans",
        contacts = "player_contacts"
    },
    redemrp = {
        characters = "characters",
        inventory = "user_inventory",
        clothes = "clothes",
        skins = "skins"
    }
}

-- ============================================================================
-- DEBUG HELPER
-- ============================================================================
local function Debug(msg)
    if Config and Config.PoggyDebug and Config.PoggyDebug.Enabled and Config.PoggyDebug.Categories.CORE then
        print("^3[POGGY-FRAMEWORK]^7 " .. msg)
    end
end

-- ============================================================================
-- FRAMEWORK DETECTION
-- ============================================================================

-- Detect which framework is being used
function PoggyFramework.Detect()
    if FrameworkDetectionComplete then
        return FrameworkType
    end
    
    -- Priority 1: Check for running framework resources
    if GetResourceState('rsg-core') == 'started' then
        FrameworkType = 'rsg'
        Debug("Detected RSG Core (resource running)")
    elseif GetResourceState('vorp_core') == 'started' then
        FrameworkType = 'vorp'
        Debug("Detected VORP Core (resource running)")
    elseif GetResourceState('qb-core') == 'started' then
        FrameworkType = 'qbcore'
        Debug("Detected QBCore (resource running)")
    elseif GetResourceState('redem_roleplay') == 'started' then
        FrameworkType = 'redemrp'
        Debug("Detected RedemRP (resource running)")
    else
        -- Priority 2: No framework detected, will use database-only mode
        FrameworkType = 'standalone'
        Debug("No framework detected - running in standalone/database mode")
    end
    
    FrameworkDetectionComplete = true
    return FrameworkType
end

-- Initialize the framework connection (with safe pcall wrapping)
function PoggyFramework.Initialize()
    local detectedType = PoggyFramework.Detect()
    
    if detectedType == 'vorp' then
        -- VORP Core has different methods depending on version
        -- Method 1: Try exports.vorp_core:vorpAPI() (newer versions)
        local success = pcall(function()
            local api = exports.vorp_core:vorpAPI()
            if api then
                FrameworkCore = api
                FrameworkReady = true
                Debug("VORP Core initialized via vorpAPI() export")
            end
        end)
        
        -- Method 2: Try TriggerEvent "getCore" (common in many VORP versions)
        if not FrameworkReady then
            local coreReceived = false
            local eventHandler = AddEventHandler("getCoreReply", function(core)
                if core then
                    FrameworkCore = core
                    FrameworkReady = true
                    coreReceived = true
                    Debug("VORP Core initialized via getCore event")
                end
            end)
            
            TriggerEvent("getCore", function(core)
                if core then
                    FrameworkCore = core
                    FrameworkReady = true
                    coreReceived = true
                    Debug("VORP Core initialized via getCore callback")
                end
            end)
            
            -- Wait briefly for callback
            local waitCount = 0
            while not coreReceived and waitCount < 20 do
                Citizen.Wait(50)
                waitCount = waitCount + 1
            end
            
            RemoveEventHandler(eventHandler)
        end
        
        -- Method 3: Try exports.vorp_core:GetCore() (older versions, might not exist)
        if not FrameworkReady then
            success = pcall(function()
                local core = exports.vorp_core:GetCore()
                if core then
                    FrameworkCore = core
                    FrameworkReady = true
                    Debug("VORP Core initialized via GetCore() export")
                end
            end)
        end
        
        -- Still not ready? Mark as standalone but with vorp type for database queries
        if not FrameworkReady then
            Debug("VORP Core detected but couldn't get core object - using database mode")
            FrameworkReady = true -- Mark ready anyway, will use database fallback
        end
        return true
        
    elseif detectedType == 'rsg' then
        local success, core = pcall(function()
            return exports['rsg-core']:GetCoreObject()
        end)
        if success and core then
            FrameworkCore = core
            FrameworkReady = true
            Debug("RSG Core initialized successfully")
            return true
        else
            Debug("RSG Core detected but couldn't get core object - using database mode")
            FrameworkReady = true
            return true
        end
        
    elseif detectedType == 'qbcore' then
        local success, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if success and core then
            FrameworkCore = core
            FrameworkReady = true
            Debug("QBCore initialized successfully")
            return true
        else
            Debug("QBCore detected but couldn't get core object - using database mode")
            FrameworkReady = true
            return true
        end
        
    elseif detectedType == 'redemrp' then
        -- RedemRP uses exports differently
        FrameworkCore = {}
        FrameworkReady = true
        Debug("RedemRP mode - using database queries")
        return true
        
    else
        -- Standalone mode - rely on database
        FrameworkReady = true
        Debug("Standalone mode initialized - database queries only")
        return true
    end
end

-- Wait for framework to be ready
function PoggyFramework.WaitUntilReady()
    local attempts = 0
    while not FrameworkReady and attempts < 100 do
        Citizen.Wait(100)
        attempts = attempts + 1
    end
    return FrameworkReady
end

-- Get the framework type
function PoggyFramework.GetType()
    if not FrameworkDetectionComplete then
        PoggyFramework.Detect()
    end
    return FrameworkType
end

-- Check if framework is ready
function PoggyFramework.IsReady()
    return FrameworkReady
end

-- Get the raw core object (use sparingly, prefer bridge functions)
function PoggyFramework.GetCore()
    return FrameworkCore
end

-- Check if a specific framework is available (by name)
function PoggyFramework.Is(frameworkName)
    return PoggyFramework.GetType() == string.lower(frameworkName)
end

-- Check if we have a valid core object (not just database mode)
function PoggyFramework.HasCore()
    return FrameworkCore ~= nil and type(FrameworkCore) == "table" and next(FrameworkCore) ~= nil
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- These are registered in the appropriate client/server files

print("^2[poggy_util]^7 Framework detection module loaded")
