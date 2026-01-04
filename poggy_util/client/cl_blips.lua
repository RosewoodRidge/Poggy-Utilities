-- File: client/cl_blips.lua
-- Description: Blip creation utilities for RedM using native functions
-- Note: RedM doesn't have AddBlipForRadius like GTA V, we use native calls

-- ============================================================================
-- DEBUG HELPER
-- ============================================================================
local function Debug(msg)
    -- Always print for now during debugging
    print("^3[POGGY-BLIPS]^7 " .. msg)
end

-- ============================================================================
-- BLIP OBJECT CLASS
-- ============================================================================

-- Create a blip object wrapper that provides :Get() and :Remove() methods
local function CreateBlipObject(rawBlip)
    local obj = {
        rawblip = rawBlip,
        
        -- Get the raw blip handle
        Get = function(self)
            return self.rawblip or 0
        end,
        
        -- Remove the blip
        Remove = function(self)
            if self.rawblip and DoesBlipExist(self.rawblip) then
                RemoveBlip(self.rawblip)
                self.rawblip = nil
                return true
            end
            return false
        end,
        
        -- Check if blip exists
        Exists = function(self)
            return self.rawblip and DoesBlipExist(self.rawblip)
        end
    }
    return obj
end

-- ============================================================================
-- BLIP NATIVES (RedM specific)
-- ============================================================================

-- Native for creating a radius blip (RedM)
-- 0x45F13B7E0A15C880 - _BLIP_ADD_FOR_RADIUS
-- Parameter order: (hash, x, y, z, radius) - hash defaults to -1282792512 for standard radius
local function N_BlipAddForRadius(x, y, z, radius, hash)
    hash = hash or -1282792512  -- Default radius blip hash
    local blip = Citizen.InvokeNative(0x45F13B7E0A15C880, hash, x + 0.0, y + 0.0, z + 0.0, radius + 0.0)
    Debug(string.format("BLIP_ADD_FOR_RADIUS (0x45F13B7E0A15C880) hash=%s, result=%s", tostring(hash), tostring(blip)))
    return blip or 0
end

-- Native for creating a coordinate blip (RedM)
-- 0x554D9D53F696D002 - _BLIP_ADD_FOR_COORDS
-- First param is blip type (1664425300 = standard), then coords
local function N_BlipAddForCoords(blipType, x, y, z)
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, blipType, x + 0.0, y + 0.0, z + 0.0)
    Debug(string.format("N_BlipAddForCoords (0x554D9D53F696D002) result: %s", tostring(blip)))
    return blip
end

-- Native for setting blip sprite
-- 0x74F74D3207ED525C - SET_BLIP_SPRITE
local function N_SetBlipSprite(blip, spriteHash, unk)
    if blip and blip ~= 0 then
        Citizen.InvokeNative(0x74F74D3207ED525C, blip, spriteHash, unk or 1)
    end
end

-- Native for setting blip color modifier
-- 0x662D364ABF16DE2F - _BLIP_SET_MODIFIER
local function N_SetBlipModifier(blip, modifierHash)
    if modifierHash and modifierHash ~= 0 and blip and blip ~= 0 then
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, modifierHash)
    end
end

-- Native for setting blip scale
-- 0xD38744167B2FA257 - SET_BLIP_SCALE
local function N_SetBlipScale(blip, scale)
    if blip and blip ~= 0 then
        Citizen.InvokeNative(0xD38744167B2FA257, blip, scale + 0.0)
    end
end

-- Native for setting blip alpha
-- 0x45FF974EEE1C8734 - SET_BLIP_ALPHA
local function N_SetBlipAlpha(blip, alpha)
    if blip and blip ~= 0 then
        Citizen.InvokeNative(0x45FF974EEE1C8734, blip, alpha)
    end
end

-- Native for setting blip name
-- 0x9CB1A1623062F402 - _SET_BLIP_NAME
local function N_SetBlipName(blip, name)
    if blip and blip ~= 0 and name then
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, name)
    end
end

-- Native for setting blip display
-- 0x9029B2F3DA924928 - SET_BLIP_DISPLAY
local function N_SetBlipDisplay(blip, displayId)
    if blip and blip ~= 0 then
        Citizen.InvokeNative(0x9029B2F3DA924928, blip, displayId)
    end
end

-- ============================================================================
-- BLIP CREATION FUNCTIONS (Compatible with Witnesses expected interface)
-- ============================================================================

--- Create a standard coordinate blip
--- Interface: CreateBlip(name, spriteHashOrName, scale, x, y, z)
---@param name string Blip display name
---@param spriteHashOrName string|number Blip sprite (string for joaat or number for hash)
---@param scale number Blip scale (default: 0.8)
---@param x number X coordinate
---@param y number Y coordinate
---@param z number Z coordinate
---@return table BlipObject with :Get() and :Remove() methods
local function CreateBlip(name, spriteHashOrName, scale, x, y, z)
    -- Sprite hash for SET_BLIP_SPRITE
    local spriteHash = nil
    if type(spriteHashOrName) == "string" then
        spriteHash = joaat(spriteHashOrName)
    elseif type(spriteHashOrName) == "number" then
        spriteHash = spriteHashOrName
    end
    
    -- Default scale
    scale = scale or 0.8
    
    Debug(string.format("CreateBlip called: name=%s, sprite=%s, scale=%.2f, coords=%.2f,%.2f,%.2f", 
        tostring(name), tostring(spriteHash), scale, x or 0, y or 0, z or 0))
    
    -- Validate coordinates
    if not x or not y or not z then
        Debug("ERROR: Invalid coordinates for CreateBlip")
        return CreateBlipObject(0)
    end
    
    -- Create the blip using native - use 1664425300 as the blip type (standard marker)
    local rawBlip = N_BlipAddForCoords(1664425300, x, y, z)
    
    Debug(string.format("N_BlipAddForCoords returned: %s (type: %s)", tostring(rawBlip), type(rawBlip)))
    
    if rawBlip and rawBlip ~= 0 then
        -- Set sprite if provided
        if spriteHash then
            N_SetBlipSprite(rawBlip, spriteHash, 1)
        end
        
        -- Set scale
        N_SetBlipScale(rawBlip, scale)
        
        -- Set name
        if name then
            N_SetBlipName(rawBlip, name)
        end
        
        -- Set display to show on both maps
        N_SetBlipDisplay(rawBlip, 4)
        
        Debug(string.format("Created blip '%s' at %.2f, %.2f, %.2f (handle: %s)", name or "unnamed", x, y, z, tostring(rawBlip)))
        return CreateBlipObject(rawBlip)
    end
    
    Debug("Failed to create blip!")
    return CreateBlipObject(0)
end

--- Create a radius blip (circle area on map)
--- Interface: CreateRadiusBlip(radius, x, y, z, colorHash)
---@param radius number Radius of the circle
---@param x number Center X coordinate
---@param y number Center Y coordinate
---@param z number Center Z coordinate
---@param colorHash number|nil Color modifier hash
---@return number rawBlip Raw blip handle (not wrapped - for direct native usage)
local function CreateRadiusBlip(radius, x, y, z, colorHash)
    Debug(string.format("CreateRadiusBlip called: radius=%.2f, coords=%.2f,%.2f,%.2f, color=%s", 
        radius or 0, x or 0, y or 0, z or 0, tostring(colorHash)))
    
    -- Validate inputs
    if not x or not y or not z or not radius then
        Debug("ERROR: Invalid parameters for CreateRadiusBlip")
        return 0
    end
    
    -- Create radius blip using AddBlipForRadius (built-in native wrapper)
    local rawBlip = N_BlipAddForRadius(x, y, z, radius)
    
    Debug(string.format("N_BlipAddForRadius returned: %s (type: %s)", tostring(rawBlip), type(rawBlip)))
    
    if rawBlip and rawBlip ~= 0 then
        -- Set color modifier if provided
        if colorHash then
            N_SetBlipModifier(rawBlip, colorHash)
        end
        
        Debug(string.format("Created radius blip at %.2f, %.2f, %.2f (radius: %.2f, handle: %s)", x, y, z, radius, tostring(rawBlip)))
        return rawBlip
    end
    
    Debug("Failed to create radius blip!")
    return 0
end

--- Remove a blip (supports both raw handle and BlipObject)
---@param blip number|table Blip handle or BlipObject
---@return boolean success Whether the blip was removed
local function RemoveBlipSafe(blip)
    if type(blip) == "table" and blip.Remove then
        return blip:Remove()
    elseif type(blip) == "number" and DoesBlipExist(blip) then
        RemoveBlip(blip)
        return true
    end
    return false
end

--- Set GPS route to coordinates
---@param x number X coordinate
---@param y number Y coordinate
---@param z number|nil Z coordinate (optional)
---@return boolean success
local function SetGPS(x, y, z)
    SetNewWaypoint(x + 0.0, y + 0.0)
    Debug(string.format("GPS set to %.2f, %.2f", x, y))
    return true
end

--- Set waypoint marker
---@param x number X coordinate
---@param y number Y coordinate
---@return boolean success
local function SetWaypoint(x, y)
    SetNewWaypoint(x + 0.0, y + 0.0)
    return true
end

--- Clear current waypoint
---@return boolean success
local function ClearWaypoint()
    local waypointBlip = GetFirstBlipInfoId(GetWaypointBlipEnumId())
    if DoesBlipExist(waypointBlip) then
        SetBlipRoute(waypointBlip, false)
        RemoveBlip(waypointBlip)
    end
    return true
end

-- ============================================================================
-- COLOR MODIFIER HASHES (for reference)
-- ============================================================================

local BlipColors = {
    WHITE = joaat("BLIP_MODIFIER_MP_COLOR_1"),
    RED = joaat("BLIP_MODIFIER_MP_COLOR_2"),
    GREEN = joaat("BLIP_MODIFIER_MP_COLOR_3"),
    BLUE = joaat("BLIP_MODIFIER_MP_COLOR_4"),
    YELLOW = joaat("BLIP_MODIFIER_MP_COLOR_5"),
    ORANGE = joaat("BLIP_MODIFIER_MP_COLOR_6"),
    PURPLE = joaat("BLIP_MODIFIER_MP_COLOR_7"),
    PINK = joaat("BLIP_MODIFIER_MP_COLOR_8"),
    DEBUG_RED = joaat("BLIP_MODIFIER_DEBUG_RED"),
    DEBUG_BLUE = joaat("BLIP_MODIFIER_DEBUG_BLUE"),
    DEBUG_GREEN = joaat("BLIP_MODIFIER_DEBUG_GREEN"),
    DEBUG_YELLOW = joaat("BLIP_MODIFIER_DEBUG_YELLOW"),
}

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('CreateBlip', CreateBlip)
exports('CreateRadiusBlip', CreateRadiusBlip)
exports('RemoveBlip', RemoveBlipSafe)
exports('SetGPS', SetGPS)
exports('SetWaypoint', SetWaypoint)
exports('ClearWaypoint', ClearWaypoint)
exports('GetBlipColors', function() return BlipColors end)

-- Raw native exports for advanced usage
exports('BlipAddForRadius', N_BlipAddForRadius)
exports('BlipAddForCoords', N_BlipAddForCoords)
exports('SetBlipModifier', N_SetBlipModifier)

print("^2[poggy_util]^7 Blip utilities loaded")
