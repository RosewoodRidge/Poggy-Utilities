PoggyUtil = PoggyUtil or {}
PoggyUtil.Music = {}

local currentZone = nil
local currentZoneLocation = nil -- The specific vector3 we are close to
local musicNuiReady = false
local lastSentVolume = -1.0

-- Load music preference from KVP (defaults to true if not set)
local function LoadMusicPreference()
    local kvpValue = GetResourceKvpInt("poggy_music_enabled")
    -- KVP returns 0 if not set, so we check if it was explicitly set to 0
    -- We use a separate key to track if the preference was ever set
    local wasSet = GetResourceKvpInt("poggy_music_preference_set")
    if wasSet == 0 then
        -- Never set before, default to true
        return true
    end
    return kvpValue == 1
end

local function SaveMusicPreference(enabled)
    SetResourceKvpInt("poggy_music_enabled", enabled and 1 or 0)
    SetResourceKvpInt("poggy_music_preference_set", 1)
end

local playerMusicEnabled = LoadMusicPreference()
local musicPreferenceLoaded = true -- KVP is always immediately available

-- Helper to convert rotation to direction vector
local function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
    return direction
end

-- Wait for config to load
Citizen.CreateThread(function()
    while Config == nil or Config.MusicZones == nil do
        Citizen.Wait(100)
    end
    
    if not Config.MusicZones.Enabled then
        PoggyUtil.DebugClient.Info("MUSIC", "Music zones are disabled via config.")
        return
    end
    
    PoggyUtil.DebugClient.Info("MUSIC", "Music zone system initialized.")
    
    -- Initialize NUI
    PoggyUtil.DebugClient.Info("MUSIC", "Sending NUI init message")
    SendNUIMessage({
        type = "init",
        quality = Config.MusicZones.Quality or 'small'
    })
    
    Citizen.Wait(1000)
    musicNuiReady = true
    PoggyUtil.DebugClient.Info("MUSIC", "Music NUI Ready set to true")
end)

-- Calculate distance-based volume (0.0 to 1.0) with 3D simulation
local function CalculateVolume(distance, maxDistance, zoneVolume, zoneCoords)
    if distance >= maxDistance then
        return 0.0
    end
    
    -- Logarithmic falloff (more realistic 3D sound)
    -- (1 - dist/max)^falloff
    local normalizedDist = distance / maxDistance
    local falloff = Config.MusicZones.Falloff or 2.0
    local volumePercent = math.pow(1.0 - normalizedDist, falloff)
    
    -- Directional Audio Simulation
    -- If enabled, lower volume when looking away from the source
    local directionalMult = 1.0
    if Config.MusicZones.DirectionalAudio and zoneCoords then
        local playerPed = PlayerPedId()
        local camRot = GetGameplayCamRot(2)
        local camForward = RotationToDirection(camRot)
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Vector from player to sound source
        local toSource = zoneCoords - playerCoords
        -- Normalize vector
        local dist = #toSource
        if dist > 0 then
            toSource = toSource / dist
            
            -- Dot product: 1.0 = looking at source, -1.0 = looking away
            local dot = (camForward.x * toSource.x) + (camForward.y * toSource.y) + (camForward.z * toSource.z)
            
            -- Map -1..1 to 0.5..1.0 (50% volume when looking away)
            directionalMult = 0.6 + (0.4 * ((dot + 1.0) / 2.0))
        end
    end
    
    -- Apply zone-specific volume, global multiplier, and directional multiplier
    local finalVol = volumePercent * zoneVolume * Config.MusicZones.VolumeMultiplier * directionalMult
    
    -- Clamp
    if finalVol < 0.0 then finalVol = 0.0 end
    if finalVol > 1.0 then finalVol = 1.0 end
    
    return finalVol
end

-- Check if player is in any music zone
local function CheckMusicZones()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local closestZone = nil
    local closestLocation = nil
    local closestDistance = math.huge
    
    -- Find the closest active zone location among all configured zones
    for _, zone in ipairs(Config.MusicZones.Zones) do
        if zone.locations then
            for _, loc in ipairs(zone.locations) do
                local distance = #(playerCoords - loc)
                
                -- Optimization: Only consider if within reasonable range (e.g. UnloadDistance * 2)
                if distance < (Config.MusicZones.UnloadDistance * 2) then
                    if distance < closestDistance then
                        closestZone = zone
                        closestLocation = loc
                        closestDistance = distance
                    end
                end
            end
        end
    end
    
    local unloadDist = Config.MusicZones.UnloadDistance or 100.0
    
    -- State Machine Logic
    -- 1. If we are currently playing a zone
    if currentZone then
        -- Check if we should switch to a closer zone that is within its audible radius
        if closestZone and closestZone ~= currentZone and closestDistance < closestZone.radius then
             -- Switch to new zone
            PoggyUtil.DebugClient.Info("MUSIC", "Switching to closer zone: %s", closestZone.name)
            currentZone = closestZone
            currentZoneLocation = closestLocation
            
            local volume = CalculateVolume(closestDistance, closestZone.radius, closestZone.volume or 1.0, closestLocation)
            
            -- Calculate random start time if timestamps are provided
            local startSeconds = 0
            if closestZone.timestamps and #closestZone.timestamps > 0 then
                startSeconds = closestZone.timestamps[math.random(#closestZone.timestamps)]
                PoggyUtil.DebugClient.Info("MUSIC", "Selected random start time: %d seconds", startSeconds)
            end

            SendNUIMessage({
                type = "play",
                youtubeId = closestZone.youtubeId,
                startSeconds = startSeconds,
                volume = volume,
                loop = closestZone.loop or true
            })
            lastSentVolume = volume

        -- Check if we are still within the Keep-Alive distance (UnloadDistance) of the CURRENT zone
        else
            -- Recalculate distance to the CURRENT active location
            local distToCurrent = #(playerCoords - currentZoneLocation)
            
            if distToCurrent > unloadDist then
                -- We are too far, unload
                PoggyUtil.DebugClient.Info("MUSIC", "Unloading zone %s (Dist: %.1f > %.1f)", currentZone.name, distToCurrent, unloadDist)
                currentZone = nil
                currentZoneLocation = nil
                SendNUIMessage({ type = "stop" })
                lastSentVolume = -1.0
            else
                -- We are within keep-alive range.
                -- Are we within audible radius?
                local volume = 0.0
                if distToCurrent < currentZone.radius then
                    volume = CalculateVolume(distToCurrent, currentZone.radius, currentZone.volume or 1.0, currentZoneLocation)
                else
                    -- We are between Radius and UnloadDistance. Keep loaded but silent.
                    volume = 0.0
                end
                
                if math.abs(volume - lastSentVolume) > 0.01 then
                    SendNUIMessage({
                        type = "updateVolume",
                        volume = volume
                    })
                    lastSentVolume = volume
                end
            end
        end
        
    -- 2. If we are NOT playing a zone
    else
        -- Check if we are inside the audible radius of the closest zone to START playing
        if closestZone and closestDistance < closestZone.radius then
            PoggyUtil.DebugClient.Info("MUSIC", "Entered radius of zone: %s", closestZone.name)
            currentZone = closestZone
            currentZoneLocation = closestLocation
            
            local volume = CalculateVolume(closestDistance, closestZone.radius, closestZone.volume or 1.0, closestLocation)
            
            -- Calculate random start time if timestamps are provided
            local startSeconds = 0
            if closestZone.timestamps and #closestZone.timestamps > 0 then
                startSeconds = closestZone.timestamps[math.random(#closestZone.timestamps)]
                PoggyUtil.DebugClient.Info("MUSIC", "Selected random start time: %d seconds", startSeconds)
            end

            SendNUIMessage({
                type = "play",
                youtubeId = closestZone.youtubeId,
                startSeconds = startSeconds,
                volume = volume,
                loop = closestZone.loop or true
            })
            lastSentVolume = volume
        end
    end
end

-- Main thread for music zone checking
Citizen.CreateThread(function()
    while not musicNuiReady do
        Citizen.Wait(500)
    end
    
    while true do
        -- Check both System Config AND Player Preference
        if Config.MusicZones.Enabled and playerMusicEnabled then
            CheckMusicZones()
            Citizen.Wait(100) -- Check every 100ms for smoother volume transitions
        else
            -- If disabled, ensure we stop any playing music
            if currentZone then
                SendNUIMessage({ type = "stop" })
                currentZone = nil
                currentZoneLocation = nil
                lastSentVolume = -1.0
            end
            Citizen.Wait(1000)
        end
    end
end)

-- Handle Character Selection - just show a tip if music is enabled
RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    Citizen.CreateThread(function()
        Citizen.Wait(5000) -- Brief delay for UI
        PoggyUtil.DebugClient.Info("MUSIC", "Character selected. Music preference (KVP): " .. tostring(playerMusicEnabled))
        if playerMusicEnabled then
            TriggerEvent("vorp:TipRight", "Music Zones Enabled", 3000)
        end
    end)
end)

-- Command to toggle music zones
RegisterCommand("togglemusic", function()
    playerMusicEnabled = not playerMusicEnabled
    
    -- Save to KVP (client-side storage)
    SaveMusicPreference(playerMusicEnabled)
    PoggyUtil.DebugClient.Info("MUSIC", "Music preference saved to KVP: " .. tostring(playerMusicEnabled))
    
    if not playerMusicEnabled then
        SendNUIMessage({
            type = "stop"
        })
        currentZone = nil
        currentZoneLocation = nil
        lastSentVolume = -1.0
    end
    
    TriggerEvent("vorp:TipRight", "Music zones " .. (playerMusicEnabled and "enabled" or "disabled"), 3000)
end, false)

PoggyUtil.DebugClient.Info("MUSIC", "Music client script loaded")
