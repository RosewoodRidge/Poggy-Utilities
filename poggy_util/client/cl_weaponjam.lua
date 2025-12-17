PoggyUtil = PoggyUtil or {}
PoggyUtil.WeaponJam = PoggyUtil.WeaponJam or {} -- Ensure the table exists

local JammedWeapons = {} -- Stores hashes of weapons that are currently jammed
local GunHashesToJam = {} -- Stores joaat hashes of weapon names from Config.WeaponJam.GunsToJam
local lastJamCheckTime = 0
local lastCleanlinessCheckTime = 0
local jamSoundInitialized = false

-- local function DebugPrint(msg)
--     if Config.WeaponJam and Config.WeaponJam.Debug then
--         print("[POGGY_UTIL_WEAPONJAM_DEBUG] " .. msg)
--     end
-- end
-- Replaced with PoggyUtil.DebugClient

-- Initialize jam sounds by preloading them
local function InitializeJamSounds()
    if jamSoundInitialized then return end
    if not Config.WeaponJam.JamSound or not Config.WeaponJam.JamSound.Enabled then return end
    
    -- Preload sounds via NUI
    SendNUIMessage({
        type = "preloadJamSounds",
        sounds = Config.WeaponJam.JamSound.Sounds
    })
    
    jamSoundInitialized = true
    PoggyUtil.DebugClient.Info("WEAPON_JAM", "Jam sounds preloaded: %d sounds", #Config.WeaponJam.JamSound.Sounds)
end

-- Play jam sound locally (only for the player whose gun jammed)
local function PlayJamSoundForSelf()
    if not Config.WeaponJam.JamSound or not Config.WeaponJam.JamSound.Enabled then return end
    
    -- Pick a random sound from the list
    local sounds = Config.WeaponJam.JamSound.Sounds
    local randomSound = sounds[math.random(#sounds)]
    
    -- Use configured gain as volume (full volume since it's our own gun)
    local volume = Config.WeaponJam.JamSound.Gain or 0.6
    
    PoggyUtil.DebugClient.Info("WEAPON_JAM", "Playing local jam sound: %s at volume: %.2f", randomSound, volume)
    
    SendNUIMessage({
        type = "playJamSound",
        sound = randomSound,
        volume = volume
    })
end

-- Check if a weapon hash is in our list of jammable weapons
local function IsWeaponJammable(weaponHash)
    local isJammable = GunHashesToJam[weaponHash] == true
    PoggyUtil.DebugClient.Trace("WEAPON_JAM", "IsWeaponJammable check for hash %s: %s", weaponHash, tostring(isJammable))
    return isJammable
end

-- Calculate the chance of jamming based on weapon degradation and config settings
function PoggyUtil.WeaponJam.CalculateJamChance(weaponHash)
    if not Config.WeaponJam.Enabled then
        PoggyUtil.DebugClient.Trace("WEAPON_JAM", "CalculateJamChance: Jamming disabled globally.")
        return 0.0
    end

    local weaponEntity = exports["poggy_util"]:GetCurrentWeaponEntity()
    if weaponEntity == 0 or not DoesEntityExist(weaponEntity) then
        PoggyUtil.DebugClient.Warning("WEAPON_JAM", "CalculateJamChance: No valid weapon entity for hash: %s", weaponHash)
        return 0.0
    end

    local degradation = GetWeaponDegradation(weaponEntity) -- 0.0 (good) to 1.0 (poor)
    PoggyUtil.DebugClient.Trace("WEAPON_JAM", "Weapon: %s, Degradation: %.2f", weaponHash, degradation)

    if degradation < Config.WeaponJam.JamStartThreshold then
        PoggyUtil.DebugClient.Trace("WEAPON_JAM", "Degradation %.2f is below threshold %.2f", degradation, Config.WeaponJam.JamStartThreshold)
        return 0.0
    end

    -- Normalize the degradation value for the part that's above the threshold
    -- This creates a 0-1 range for how "bad" the weapon is past the jamming threshold
    local effectiveDegradationRange = 1.0 - Config.WeaponJam.JamStartThreshold
    if effectiveDegradationRange <= 0 then -- Avoid division by zero or negative if config is bad
        PoggyUtil.DebugClient.Warning("WEAPON_JAM", "JamStartThreshold is 1.0 or higher, cannot calculate effective degradation.")
        return Config.WeaponJam.MaxJamProbability -- Max chance if threshold is 1.0 and degradation is 1.0
    end
    
    local normalizedDegradation = (degradation - Config.WeaponJam.JamStartThreshold) / effectiveDegradationRange
    normalizedDegradation = math.max(0, math.min(1, normalizedDegradation)) -- Clamp between 0 and 1

    -- Apply exponent to make the chance increase more steeply
    local jamChance = (normalizedDegradation ^ Config.WeaponJam.JamChanceExponent) * Config.WeaponJam.MaxJamProbability
    jamChance = math.min(jamChance, Config.WeaponJam.MaxJamProbability) -- Ensure it doesn't exceed max probability

    PoggyUtil.DebugClient.Trace("WEAPON_JAM", "Normalized Degradation: %.2f, Calculated Jam Chance: %.3f", normalizedDegradation, jamChance)
    return jamChance
end

-- Attempt to jam the currently equipped weapon
function PoggyUtil.WeaponJam.AttemptToJamWeapon(weaponHash)
    if not Config.WeaponJam.Enabled then
        PoggyUtil.DebugClient.Trace("WEAPON_JAM_FIRE", "AttemptToJamWeapon: Jamming disabled globally.")
        return false -- Return false if not jammed
    end
    if JammedWeapons[weaponHash] then
        PoggyUtil.DebugClient.Trace("WEAPON_JAM_FIRE", "AttemptToJamWeapon: Weapon %s already jammed.", weaponHash)
        return true -- Already jammed
    end
    if not IsWeaponJammable(weaponHash) then
         PoggyUtil.DebugClient.Trace("WEAPON_JAM_FIRE", "AttemptToJamWeapon: Weapon %s is not jammable type.", weaponHash)
        return false -- Not a jammable type
    end


    local jamChance = PoggyUtil.WeaponJam.CalculateJamChance(weaponHash)
    PoggyUtil.DebugClient.Info("WEAPON_JAM_FIRE", "AttemptToJamWeapon: Hash: %s, Degradation: %.2f (from GetCurrentWeaponEntity), Jammable: %s, Calculated Jam Chance: %.3f",
        weaponHash, GetWeaponDegradation(exports["poggy_util"]:GetCurrentWeaponEntity()), tostring(IsWeaponJammable(weaponHash)), jamChance)

    if math.random() < jamChance then -- math.random() gives a float between 0.0 and 1.0
        JammedWeapons[weaponHash] = true
        PoggyUtil.DebugClient.Info("WEAPON_JAM", "Weapon %s JAMMED! (Chance: %.3f)", weaponHash, jamChance)
        
        -- Play the jam sound locally (only for this player)
        PlayJamSoundForSelf()
        
        return true -- Jammed
    else
        PoggyUtil.DebugClient.Info("WEAPON_JAM_FIRE", "Weapon %s did NOT jam. (Roll vs Chance: %.3f)", weaponHash, jamChance)
        return false -- Not jammed
    end
end

-- Public function to check if a weapon is jammed (for export)
function PoggyUtil.WeaponJam.IsWeaponJammed(weaponHash)
    return JammedWeapons[weaponHash] == true
end

-- Export defined in the same file as the function
exports("IsWeaponJammed", PoggyUtil.WeaponJam.IsWeaponJammed)

-- New function to check if a jammed weapon is now clean enough to be functional
function PoggyUtil.WeaponJam.CheckWeaponCleanliness()
    if not Config.WeaponJam.Enabled or not next(JammedWeapons) then 
        return -- No jammed weapons or system disabled
    end
    
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        PoggyUtil.DebugClient.Trace("WEAPON_JAM", "CheckWeaponCleanliness: Player does not exist or is dead.")
        return
    end
    
    -- Get current weapon
    local currentWeaponHash = PoggyUtil.Weapon.GetCurrentWeaponHash()
    
    -- First check if current weapon is jammed
    if JammedWeapons[currentWeaponHash] then
        local weaponEntity = PoggyUtil.Weapon.GetCurrentWeaponEntity()
        if weaponEntity ~= 0 and DoesEntityExist(weaponEntity) then
            local degradation = GetWeaponDegradation(weaponEntity)
            PoggyUtil.DebugClient.Info("WEAPON_JAM", "Checking jammed weapon cleanliness - Hash: %s, Current degradation: %.3f, Unjam threshold: %.3f", 
                currentWeaponHash, degradation, Config.WeaponJam.UnjamThreshold)
            
            -- If weapon is now clean enough, remove it from jammed weapons
            if degradation <= Config.WeaponJam.UnjamThreshold then
                JammedWeapons[currentWeaponHash] = nil
                PoggyUtil.DebugClient.Info("WEAPON_JAM", "Weapon %s is now clean and functional (Degradation: %.3f)", currentWeaponHash, degradation)
            else
                PoggyUtil.DebugClient.Info("WEAPON_JAM", "Weapon %s still too dirty to unjam (Degradation: %.3f, Threshold: %.3f)", 
                    currentWeaponHash, degradation, Config.WeaponJam.UnjamThreshold)
            end
        else
            PoggyUtil.DebugClient.Warning("WEAPON_JAM", "Could not get entity for jammed weapon %s", currentWeaponHash)
        end
    end
    
    -- Secondary check: remove any weapons from JammedWeapons that are now clean
    -- This is useful for cases where a player unjammed a weapon while it wasn't equipped
    local weaponsToRemove = {}
    for jammedHash, _ in pairs(JammedWeapons) do
        -- Skip the current weapon as we already checked it
        if jammedHash ~= currentWeaponHash then
            -- Use HasPedGotWeapon to check if the player has this weapon in inventory
            if HasPedGotWeapon(ped, jammedHash, false, false) then
                -- We can't check degradation of weapons not in hand, so we'll remove them
                -- from JammedWeapons and let them re-jam if they're still dirty when used
                table.insert(weaponsToRemove, jammedHash)
                PoggyUtil.DebugClient.Info("WEAPON_JAM", "Removing holstered weapon %s from jammed list - will recheck when equipped", jammedHash)
            end
        end
    end
    
    -- Remove weapons outside the loop to avoid issues
    for _, hash in ipairs(weaponsToRemove) do
        JammedWeapons[hash] = nil
    end
end

-- Main thread for handling weapon jamming logic
Citizen.CreateThread(function()
    Citizen.Wait(100) -- Add a small delay to ensure all scripts and exports are initialized

    -- Wait for config to be available
    while Config.WeaponJam == nil or Config.PoggyDebug == nil or PoggyUtil.DebugClient == nil do
        Citizen.Wait(1000)
    end

    if not Config.WeaponJam.Enabled then
        PoggyUtil.DebugClient.Info("WEAPON_JAM", "Weapon Jamming is disabled via config.")
        return
    end

    -- Populate GunHashesToJam from config weapon names
    for _, weaponName in ipairs(Config.WeaponJam.GunsToJam) do
        GunHashesToJam[GetHashKey(weaponName)] = true
    end
    PoggyUtil.DebugClient.Info("WEAPON_JAM", "Weapon Jamming initialized. Jammable gun types: %d", #Config.WeaponJam.GunsToJam)
    
    -- Initialize jam sounds
    InitializeJamSounds()

    while true do
        Citizen.Wait(0) -- Run frequently to check player state

        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local currentWeaponHash = exports["poggy_util"]:GetCurrentWeaponHash()

            if currentWeaponHash and currentWeaponHash ~= GetHashKey("WEAPON_UNARMED") then
                if JammedWeapons[currentWeaponHash] then
                    -- Check if player tries to fire while jammed BEFORE disabling firing
                    -- INPUT_ATTACK = 0x07CE1E61 (Left Mouse / Right Trigger)
                    local tryingToFire = IsControlJustPressed(0, 0x07CE1E61) or IsDisabledControlJustPressed(0, 0x07CE1E61)
                    
                    DisablePlayerFiring(ped, true) -- Disable firing if current weapon is jammed
                    
                    if tryingToFire then
                        PoggyUtil.DebugClient.Trace("WEAPON_JAM", "Player tried to fire jammed weapon (Trigger pulled)")
                        PlayJamSoundForSelf()
                    end
                end

                -- Check for jam attempt only when shooting and weapon is jammable type
                if IsPedShooting(ped) and not JammedWeapons[currentWeaponHash] then -- No need to check IsWeaponJammable here, AttemptToJamWeapon does it
                    local currentTime = GetGameTimer()
                    if (currentTime - lastJamCheckTime) > Config.WeaponJam.JamCheckInterval then
                        PoggyUtil.DebugClient.Trace("WEAPON_JAM_FIRE", "Player is shooting with %s. Checking for jam.", currentWeaponHash)
                        PoggyUtil.WeaponJam.AttemptToJamWeapon(currentWeaponHash)
                        lastJamCheckTime = currentTime
                    end
                end
                
                -- Periodically check if jammed weapons have been cleaned and should be unjammed
                local currentTime = GetGameTimer()
                if (currentTime - lastCleanlinessCheckTime) > Config.WeaponJam.CleanlinessCheckInterval then
                    PoggyUtil.WeaponJam.CheckWeaponCleanliness()
                    lastCleanlinessCheckTime = currentTime
                end
            end
        end
    end
end)
