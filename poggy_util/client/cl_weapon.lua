PoggyUtil = PoggyUtil or {}
PoggyUtil.Weapon = PoggyUtil.Weapon or {} -- Ensure the table exists

-- Function to get the hash of the currently equipped weapon
function PoggyUtil.Weapon.GetCurrentWeaponHash()
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
    PoggyUtil.DebugClient.Trace("WEAPON", "GetCurrentWeaponHash called, result: %s", weaponHash)
    return weaponHash
end

-- Function to get the entity of the currently equipped weapon
function PoggyUtil.Weapon.GetCurrentWeaponEntity()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) and not IsEntityDead(ped) then
        local _, weaponHash = GetCurrentPedWeapon(ped, true)
        if weaponHash ~= 0 and weaponHash ~= GetHashKey("WEAPON_UNARMED") then
            -- Fix: Changed GetCurrentPedWeaponEntity to GetCurrentPedWeaponEntityIndex with attachPoint 0
            local entity = GetCurrentPedWeaponEntityIndex(ped, 0) -- Using attach point 0 (right hand/primary weapon)
            PoggyUtil.DebugClient.Trace("WEAPON", "GetCurrentWeaponEntity called, entity: %s for weapon hash: %s", entity, weaponHash)
            return entity
        else
            PoggyUtil.DebugClient.Trace("WEAPON", "GetCurrentWeaponEntity: Player unarmed or invalid weapon hash %s.", weaponHash)
        end
    else
        PoggyUtil.DebugClient.Trace("WEAPON", "GetCurrentWeaponEntity: Ped does not exist or is dead.")
    end
    return 0 -- Return 0 if no valid weapon entity
end

-- Exports defined in the same file as the functions
exports("GetCurrentWeaponHash", PoggyUtil.Weapon.GetCurrentWeaponHash)
exports("GetCurrentWeaponEntity", PoggyUtil.Weapon.GetCurrentWeaponEntity)
