PoggyUtil = PoggyUtil or {}
PoggyUtil.Player = {}

local VORPCore = nil

Citizen.CreateThread(function()
    while VORPCore == nil do
        VORPCore = exports.vorp_core:GetCore()
        if VORPCore == nil then
            if PoggyUtil.DebugServer and PoggyUtil.DebugServer.Warning then -- Check if debug is loaded
                PoggyUtil.DebugServer.Warning("PLAYER", "Waiting for VORP Core...")
            else
                print("[POGGY_UTIL_PLAYER] Waiting for VORP Core... (Debug not yet loaded)")
            end
            Citizen.Wait(1000)
        end
    end
    if VORPCore then
        PoggyUtil.DebugServer.Info("PLAYER", "VORP Core loaded.")
    end
end)

-- Function to get VORP character information for a player
-- Inspired by: witnesses/server/core.lua
function PoggyUtil.Player.GetCharacterInfo(source)
    if not VORPCore then
        PoggyUtil.DebugServer.Error("PLAYER", "GetCharacterInfo: VORP Core is not available.")
        return nil
    end

    local src = tonumber(source)
    if not src or src <= 0 then
        PoggyUtil.DebugServer.Error("PLAYER", "GetCharacterInfo: Invalid source provided: %s", tostring(source))
        return nil
    end

    local user = VORPCore.getUser(src)
    if not user then
        PoggyUtil.DebugServer.Warning("PLAYER", "GetCharacterInfo: User not found for source %s", src)
        return nil
    end

    local character = user.getUsedCharacter
    if not character then
        PoggyUtil.DebugServer.Warning("PLAYER", "GetCharacterInfo: Character not found for user %s", src)
        return nil
    end
    
    PoggyUtil.DebugServer.Trace("PLAYER", "GetCharacterInfo: Successfully retrieved info for source %s, CharID: %s", src, character.charIdentifier)

    return {
        charId = character.charIdentifier,
        identifier = character.identifier,
        firstname = character.firstname,
        lastname = character.lastname,
        job = character.job,
        jobGrade = character.jobGrade,
        group = character.group -- VORP often includes group/gang info here
    }
end
