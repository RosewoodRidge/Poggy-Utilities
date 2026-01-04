-- File: cl_notifications.lua
-- Description: Native RedM notification system (standalone, no external dependencies)
-- Ported from VORP Core notifications for use with poggy_util
-- Uses native game UI - no custom HTML/CSS needed

-------------------------------------------------------------------------------------------------------------
-- DATAVIEW FUNCTIONS
-- Big thanks to gottfriedleibniz for this DataView in LUA.
-- https://gist.github.com/gottfriedleibniz/8ff6e4f38f97dd43354a60f8494eedff
-------------------------------------------------------------------------------------------------------------

local _strblob = string.blob or function(length)
    return string.rep("\0", math.max(40 + 1, length))
end

local DataView = {
    EndBig = ">",
    EndLittle = "<",
    Types = {
        Int8 = { code = "i1", size = 1 },
        Uint8 = { code = "I1", size = 1 },
        Int16 = { code = "i2", size = 2 },
        Uint16 = { code = "I2", size = 2 },
        Int32 = { code = "i4", size = 4 },
        Uint32 = { code = "I4", size = 4 },
        Int64 = { code = "i8", size = 8 },
        Uint64 = { code = "I8", size = 8 },
        LuaInt = { code = "j", size = 8 },
        UluaInt = { code = "J", size = 8 },
        LuaNum = { code = "n", size = 8 },
        Float32 = { code = "f", size = 4 },
        Float64 = { code = "d", size = 8 },
        String = { code = "z", size = -1, },
    },
    FixedTypes = {
        String = { code = "c", size = -1, },
        Int = { code = "i", size = -1, },
        Uint = { code = "I", size = -1, },
    },
}
DataView.__index = DataView

local function _ib(o, l, t) return ((t.size < 0 and true) or (o + (t.size - 1) <= l)) end
local function _ef(big) return (big and DataView.EndBig) or DataView.EndLittle end

local SetFixed = nil

function DataView.ArrayBuffer(length)
    return setmetatable({
        offset = 1, length = length, blob = _strblob(length)
    }, DataView)
end

function DataView.Wrap(blob)
    return setmetatable({
        offset = 1, blob = blob, length = blob:len(),
    }, DataView)
end

function DataView:Buffer() return self.blob end
function DataView:ByteLength() return self.length end
function DataView:ByteOffset() return self.offset end

function DataView:SubView(offset)
    return setmetatable({
        offset = offset, blob = self.blob, length = self.length,
    }, DataView)
end

for label, datatype in pairs(DataView.Types) do
    DataView["Get" .. label] = function(self, offset, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            local v, _ = string.unpack(_ef(endian) .. datatype.code, self.blob, o)
            return v
        end
        return nil
    end

    DataView["Set" .. label] = function(self, offset, value, endian)
        local o = self.offset + offset
        if _ib(o, self.length, datatype) then
            return SetFixed(self, o, value, _ef(endian) .. datatype.code)
        end
        return self
    end
end

for label, datatype in pairs(DataView.FixedTypes) do
    DataView["GetFixed" .. label] = function(self, offset, typelen, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. "c" .. tostring(typelen)
            local v, _ = string.unpack(code, self.blob, o)
            return v
        end
        return nil
    end
    DataView["SetFixed" .. label] = function(self, offset, typelen, value, endian)
        local o = self.offset + offset
        if o + (typelen - 1) <= self.length then
            local code = _ef(endian) .. "c" .. tostring(typelen)
            return SetFixed(self, o, value, code)
        end
        return self
    end
end

SetFixed = function(self, offset, value, code)
    local fmt = {}
    local values = {}
    if self.offset < offset then
        local size = offset - self.offset
        fmt[#fmt + 1] = "c" .. tostring(size)
        values[#values + 1] = self.blob:sub(self.offset, size)
    end
    fmt[#fmt + 1] = code
    values[#values + 1] = value
    local ps = string.packsize(fmt[#fmt])
    if (offset + ps) <= self.length then
        local newoff = offset + ps
        local size = self.length - newoff + 1
        fmt[#fmt + 1] = "c" .. tostring(size)
        values[#values + 1] = self.blob:sub(newoff, self.length)
    end
    self.blob = string.pack(table.concat(fmt, ""), table.unpack(values))
    self.length = self.blob:len()
    return self
end

-------------------------------------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
-------------------------------------------------------------------------------------------------------------

local function LoadTexture(hash)
    if not HasStreamedTextureDictLoaded(hash) then
        RequestStreamedTextureDict(hash, true)
        local timeout = 0
        repeat 
            Citizen.Wait(0) 
            timeout = timeout + 1
        until HasStreamedTextureDictLoaded(hash) or timeout > 100
        return HasStreamedTextureDictLoaded(hash)
    end
    return true
end

local function BigInt(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end

local function joaat(str)
    return GetHashKey(str)
end

-------------------------------------------------------------------------------------------------------------
-- POGGY NOTIFICATION CLASS
-------------------------------------------------------------------------------------------------------------

PoggyNotification = setmetatable({}, {})
PoggyNotification.__index = PoggyNotification
PoggyNotification.__call = function()
    return 'PoggyNotifications'
end

---NotifyLeft - Left side notification with icon
---@param title string
---@param subtitle string
---@param dict string - texture dictionary
---@param icon string - icon name
---@param duration? number - default 3000
---@param color? string - default COLOR_WHITE
function PoggyNotification:NotifyLeft(title, subtitle, dict, icon, duration, color)
    -- Debug print to trace if this function is being called
    print(string.format("^3[poggy_util:NotifyLeft]^7 title=%s, subtitle=%s, dict=%s, icon=%s, duration=%s, color=%s",
        tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tostring(duration), tostring(color)))
    
    LoadTexture(dict)

    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
    
    local structData = DataView.ArrayBuffer(8 * 8)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", subtitle)))
    structData:SetInt32(8 * 3, 0)
    structData:SetInt64(8 * 4, BigInt(joaat(dict)))
    structData:SetInt64(8 * 5, BigInt(joaat(icon)))
    structData:SetInt64(8 * 6, BigInt(joaat(color or "COLOR_WHITE")))

    Citizen.InvokeNative(0x26E87218390E6729, structConfig:Buffer(), structData:Buffer(), 1, 1)
    Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict) -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
end

---NotifyTip - Simple tip notification (center-bottom)
---@param tipMessage string
---@param duration? number - default 3000
function PoggyNotification:NotifyTip(tipMessage, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
    structConfig:SetInt32(8 * 1, 0)
    structConfig:SetInt32(8 * 2, 0)
    structConfig:SetInt32(8 * 3, 0)

    local structData = DataView.ArrayBuffer(8 * 3)
    structData:SetUint64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", tipMessage)))

    Citizen.InvokeNative(0x049D5C615BD38BAD, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyTop - Top notification with location
---@param message string
---@param location string
---@param duration? number - default 3000
function PoggyNotification:NotifyTop(message, location, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 5)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", location)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", message)))

    Citizen.InvokeNative(0xD05590C1AB38F068, structConfig:Buffer(), structData:Buffer(), 0, 1)
end

---NotifyRightTip - Tip notification on the right side
---@param tipMessage string
---@param duration? number - default 3000
function PoggyNotification:NotifyRightTip(tipMessage, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 3)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", tipMessage)))

    Citizen.InvokeNative(0xB2920B9760F0F36B, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyObjective - Objective/mission style notification (bottom)
---@param message string
---@param duration? number - default 3000
function PoggyNotification:NotifyObjective(message, duration)
    Citizen.InvokeNative(0xDD1232B332CBB9E7, 3, 1, 0)

    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 3)
    local strMessage = VarString(10, "LITERAL_STRING", message)
    structData:SetInt64(8 * 1, BigInt(strMessage))

    Citizen.InvokeNative(0xCEDBF17EFCC0E4A4, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifySimpleTop - Simple top notification with title and subtitle
---@param title string
---@param subtitle string
---@param duration? number - default 3000
function PoggyNotification:NotifySimpleTop(title, subtitle, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 7)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", subtitle)))

    Citizen.InvokeNative(0xA6F4216AB10EB08E, structConfig:Buffer(), structData:Buffer(), 1, 1)
end

---NotifyAdvanced - Advanced notification with icon and optional quality
---@param text string
---@param dict string - texture dictionary
---@param icon string - icon name
---@param text_color string - color name
---@param duration? number - default 3000
---@param quality? number - default 1
---@param showquality? boolean - default false
function PoggyNotification:NotifyAdvanced(text, dict, icon, text_color, duration, quality, showquality)
    LoadTexture(dict)

    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
    structConfig:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", "Transaction_Feed_Sounds")))
    structConfig:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", "Transaction_Positive")))

    local structData = DataView.ArrayBuffer(8 * 10)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", text)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", dict)))
    structData:SetInt64(8 * 3, BigInt(joaat(icon)))
    structData:SetInt64(8 * 5, BigInt(joaat(text_color or "COLOR_WHITE")))
    if showquality then
        structData:SetInt32(8 * 6, quality or 1)
    end

    Citizen.InvokeNative(0xB249EBCB30DD88E0, structConfig:Buffer(), structData:Buffer(), 1)
    Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict) -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
end

---NotifyBasicTop - Basic top notification
---@param text string
---@param duration? number - default 3000
function PoggyNotification:NotifyBasicTop(text, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 7)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", text)))

    Citizen.InvokeNative(0x7AE0589093A2E088, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyCenter - Center screen notification
---@param text string
---@param duration? number - default 3000
---@param text_color? string - default COLOR_PURE_WHITE
function PoggyNotification:NotifyCenter(text, duration, text_color)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 4)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", text)))
    structData:SetInt64(8 * 2, BigInt(joaat(text_color or "COLOR_PURE_WHITE")))

    Citizen.InvokeNative(0x893128CDB4B81FBB, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyBottomRight - Bottom right notification
---@param text string
---@param duration? number - default 3000
function PoggyNotification:NotifyBottomRight(text, duration)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))

    local structData = DataView.ArrayBuffer(8 * 5)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", text)))

    Citizen.InvokeNative(0x2024F4F333095FB1, structConfig:Buffer(), structData:Buffer(), 1)
end

---NotifyFail - Mission failed style notification
---@param title string
---@param subtitle string
---@param duration? number - default 3000
function PoggyNotification:NotifyFail(title, subtitle, duration)
    local structConfig = DataView.ArrayBuffer(8 * 5)

    local structData = DataView.ArrayBuffer(8 * 9)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", subtitle)))

    local result = Citizen.InvokeNative(0x9F2CC2439A04E7BA, structConfig:Buffer(), structData:Buffer(), 1)
    Citizen.Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyDead - Player dead notification
---@param title string
---@param audioRef string
---@param audioName string
---@param duration? number - default 3000
function PoggyNotification:NotifyDead(title, audioRef, audioName, duration)
    local structConfig = DataView.ArrayBuffer(8 * 5)

    local structData = DataView.ArrayBuffer(8 * 9)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", audioRef)))
    structData:SetInt64(8 * 3, BigInt(VarString(10, "LITERAL_STRING", audioName)))

    local result = Citizen.InvokeNative(0x815C4065AE6E6071, structConfig:Buffer(), structData:Buffer(), 1)
    Citizen.Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyUpdate - Mission update notification
---@param title string
---@param message string
---@param duration? number - default 3000
function PoggyNotification:NotifyUpdate(title, message, duration)
    local structConfig = DataView.ArrayBuffer(8 * 5)

    local structData = DataView.ArrayBuffer(8 * 9)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", message)))

    local result = Citizen.InvokeNative(0x339E16B41780FC35, structConfig:Buffer(), structData:Buffer(), 1)
    Citizen.Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyWarning - Warning notification with audio
---@param title string
---@param message string
---@param audioRef string
---@param audioName string
---@param duration? number - default 3000
function PoggyNotification:NotifyWarning(title, message, audioRef, audioName, duration)
    local structConfig = DataView.ArrayBuffer(8 * 5)

    local structData = DataView.ArrayBuffer(8 * 9)
    structData:SetInt64(8 * 1, BigInt(VarString(10, "LITERAL_STRING", title)))
    structData:SetInt64(8 * 2, BigInt(VarString(10, "LITERAL_STRING", message)))
    structData:SetInt64(8 * 3, BigInt(VarString(10, "LITERAL_STRING", audioRef)))
    structData:SetInt64(8 * 4, BigInt(VarString(10, "LITERAL_STRING", audioName)))

    local result = Citizen.InvokeNative(0x339E16B41780FC35, structConfig:Buffer(), structData:Buffer(), 1)
    Citizen.Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

---NotifyLeftRank - Left notification with rank/icon
---@param title string
---@param subtitle string
---@param dict string - texture dictionary
---@param texture string - texture name
---@param duration? number - default 5000
---@param color? string - default COLOR_WHITE
function PoggyNotification:NotifyLeftRank(title, subtitle, dict, texture, duration, color)
    LoadTexture(dict)
    duration = duration or 5000
    local dictHash = joaat(dict or "TOASTS_MP_GENERIC")
    local textureHash = joaat(texture or "toast_mp_standalone_sp")
    local string1 = VarString(10, "LITERAL_STRING", title)
    local string2 = VarString(10, "LITERAL_STRING", subtitle)

    local struct1 = DataView.ArrayBuffer(8 * 8)
    local struct2 = DataView.ArrayBuffer(8 * 10)

    struct1:SetInt32(8 * 0, duration)

    struct2:SetInt64(8 * 1, BigInt(string1))
    struct2:SetInt64(8 * 2, BigInt(string2))
    struct2:SetInt64(8 * 4, BigInt(dictHash))
    struct2:SetInt64(8 * 5, BigInt(textureHash))
    struct2:SetInt64(8 * 6, BigInt(joaat(color or "COLOR_WHITE")))
    struct2:SetInt32(8 * 7, 1)
    
    Citizen.InvokeNative(0x3F9FDDBA79117C69, struct1:Buffer(), struct2:Buffer(), 1, 1)
    Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict) -- SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED
end

-------------------------------------------------------------------------------------------------------------
-- REGISTER EVENT HANDLERS (VORP-Compatible Events)
-- These allow other scripts to call notifications via TriggerEvent using the familiar vorp: prefix
-- OR using the new poggy: prefix
-------------------------------------------------------------------------------------------------------------

-- Register both poggy: and vorp: events for backwards compatibility
local eventPrefixes = {'poggy:', 'vorp:'}

for _, prefix in ipairs(eventPrefixes) do
    RegisterNetEvent(prefix .. 'NotifyLeft')
    RegisterNetEvent(prefix .. 'Tip')
    RegisterNetEvent(prefix .. 'NotifyTop')
    RegisterNetEvent(prefix .. 'TipRight')
    RegisterNetEvent(prefix .. 'TipBottom')
    RegisterNetEvent(prefix .. 'ShowTopNotification')
    RegisterNetEvent(prefix .. 'ShowAdvancedNotification')
    RegisterNetEvent(prefix .. 'ShowAdvancedRightNotification')
    RegisterNetEvent(prefix .. 'ShowBasicTopNotification')
    RegisterNetEvent(prefix .. 'ShowSimpleCenterText')
    RegisterNetEvent(prefix .. 'ShowBottomRight')
    RegisterNetEvent(prefix .. 'failmissioNotifY')
    RegisterNetEvent(prefix .. 'deadplayerNotifY')
    RegisterNetEvent(prefix .. 'updatemissioNotify')
    RegisterNetEvent(prefix .. 'warningNotify')
    RegisterNetEvent(prefix .. 'LeftRank')
end

-- Event Handlers
AddEventHandler('poggy:NotifyLeft', function(firsttext, secondtext, dict, icon, duration, color)
    PoggyNotification:NotifyLeft(tostring(firsttext), tostring(secondtext), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end)
AddEventHandler('vorp:NotifyLeft', function(firsttext, secondtext, dict, icon, duration, color)
    PoggyNotification:NotifyLeft(tostring(firsttext), tostring(secondtext), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end)

AddEventHandler('poggy:Tip', function(text, duration)
    PoggyNotification:NotifyTip(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:Tip', function(text, duration)
    PoggyNotification:NotifyTip(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:NotifyTop', function(text, location, duration)
    PoggyNotification:NotifyTop(tostring(text), tostring(location), tonumber(duration))
end)
AddEventHandler('vorp:NotifyTop', function(text, location, duration)
    PoggyNotification:NotifyTop(tostring(text), tostring(location), tonumber(duration))
end)

AddEventHandler('poggy:TipRight', function(text, duration)
    PoggyNotification:NotifyRightTip(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:TipRight', function(text, duration)
    PoggyNotification:NotifyRightTip(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:TipBottom', function(text, duration)
    PoggyNotification:NotifyObjective(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:TipBottom', function(text, duration)
    PoggyNotification:NotifyObjective(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:ShowTopNotification', function(title, subtitle, duration)
    PoggyNotification:NotifySimpleTop(tostring(title), tostring(subtitle), tonumber(duration))
end)
AddEventHandler('vorp:ShowTopNotification', function(title, subtitle, duration)
    PoggyNotification:NotifySimpleTop(tostring(title), tostring(subtitle), tonumber(duration))
end)

AddEventHandler('poggy:ShowAdvancedNotification', function(text, dict, icon, text_color, duration, quality)
    PoggyNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality)
end)
AddEventHandler('vorp:ShowAdvancedNotification', function(text, dict, icon, text_color, duration, quality)
    PoggyNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality)
end)

AddEventHandler('poggy:ShowAdvancedRightNotification', function(text, dict, icon, text_color, duration, quality)
    PoggyNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality)
end)
AddEventHandler('vorp:ShowAdvancedRightNotification', function(text, dict, icon, text_color, duration, quality)
    PoggyNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality)
end)

AddEventHandler('poggy:ShowBasicTopNotification', function(text, duration)
    PoggyNotification:NotifyBasicTop(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:ShowBasicTopNotification', function(text, duration)
    PoggyNotification:NotifyBasicTop(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:ShowSimpleCenterText', function(text, duration)
    PoggyNotification:NotifyCenter(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:ShowSimpleCenterText', function(text, duration)
    PoggyNotification:NotifyCenter(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:ShowBottomRight', function(text, duration)
    PoggyNotification:NotifyBottomRight(tostring(text), tonumber(duration))
end)
AddEventHandler('vorp:ShowBottomRight', function(text, duration)
    PoggyNotification:NotifyBottomRight(tostring(text), tonumber(duration))
end)

AddEventHandler('poggy:failmissioNotifY', function(title, subtitle, duration)
    PoggyNotification:NotifyFail(tostring(title), tostring(subtitle), tonumber(duration))
end)
AddEventHandler('vorp:failmissioNotifY', function(title, subtitle, duration)
    PoggyNotification:NotifyFail(tostring(title), tostring(subtitle), tonumber(duration))
end)

AddEventHandler('poggy:deadplayerNotifY', function(title, audioRef, audioName, duration)
    PoggyNotification:NotifyDead(tostring(title), tostring(audioRef), tostring(audioName), tonumber(duration))
end)
AddEventHandler('vorp:deadplayerNotifY', function(title, audioRef, audioName, duration)
    PoggyNotification:NotifyDead(tostring(title), tostring(audioRef), tostring(audioName), tonumber(duration))
end)

AddEventHandler('poggy:updatemissioNotify', function(utitle, umsg, duration)
    PoggyNotification:NotifyUpdate(tostring(utitle), tostring(umsg), tonumber(duration))
end)
AddEventHandler('vorp:updatemissioNotify', function(utitle, umsg, duration)
    PoggyNotification:NotifyUpdate(tostring(utitle), tostring(umsg), tonumber(duration))
end)

AddEventHandler('poggy:warningNotify', function(title, msg, audioRef, audioName, duration)
    PoggyNotification:NotifyWarning(tostring(title), tostring(msg), tostring(audioRef), tostring(audioName), tonumber(duration))
end)
AddEventHandler('vorp:warningNotify', function(title, msg, audioRef, audioName, duration)
    PoggyNotification:NotifyWarning(tostring(title), tostring(msg), tostring(audioRef), tostring(audioName), tonumber(duration))
end)

AddEventHandler('poggy:LeftRank', function(title, subtitle, dict, icon, duration, color)
    PoggyNotification:NotifyLeftRank(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color))
end)
AddEventHandler('vorp:LeftRank', function(title, subtitle, dict, icon, duration, color)
    PoggyNotification:NotifyLeftRank(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color))
end)

-------------------------------------------------------------------------------------------------------------
-- EXPORTS
-------------------------------------------------------------------------------------------------------------

-- Direct function exports for use with exports.poggy_util:FunctionName()
exports("NotifyTip", function(text, duration)
    PoggyNotification:NotifyTip(tostring(text), tonumber(duration))
end)

exports("NotifyLeft", function(title, subtitle, dict, icon, duration, color)
    PoggyNotification:NotifyLeft(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end)

exports("NotifyRightTip", function(text, duration)
    PoggyNotification:NotifyRightTip(tostring(text), tonumber(duration))
end)

exports("NotifyObjective", function(text, duration)
    PoggyNotification:NotifyObjective(tostring(text), tonumber(duration))
end)

exports("NotifyTop", function(text, location, duration)
    PoggyNotification:NotifyTop(tostring(text), tostring(location), tonumber(duration))
end)

exports("NotifySimpleTop", function(title, subtitle, duration)
    PoggyNotification:NotifySimpleTop(tostring(title), tostring(subtitle), tonumber(duration))
end)

exports("NotifyAdvanced", function(text, dict, icon, text_color, duration, quality, showquality)
    PoggyNotification:NotifyAdvanced(tostring(text), tostring(dict), tostring(icon), tostring(text_color), tonumber(duration), quality, showquality)
end)

exports("NotifyBasicTop", function(text, duration)
    PoggyNotification:NotifyBasicTop(tostring(text), tonumber(duration))
end)

exports("NotifyCenter", function(text, duration, text_color)
    PoggyNotification:NotifyCenter(tostring(text), tonumber(duration), tostring(text_color))
end)

exports("NotifyBottomRight", function(text, duration)
    PoggyNotification:NotifyBottomRight(tostring(text), tonumber(duration))
end)

exports("NotifyFail", function(title, subtitle, duration)
    PoggyNotification:NotifyFail(tostring(title), tostring(subtitle), tonumber(duration))
end)

exports("NotifyDead", function(title, audioRef, audioName, duration)
    PoggyNotification:NotifyDead(tostring(title), tostring(audioRef), tostring(audioName), tonumber(duration))
end)

exports("NotifyUpdate", function(title, message, duration)
    PoggyNotification:NotifyUpdate(tostring(title), tostring(message), tonumber(duration))
end)

exports("NotifyWarning", function(title, message, audioRef, audioName, duration)
    PoggyNotification:NotifyWarning(tostring(title), tostring(message), tostring(audioRef), tostring(audioName), tonumber(duration))
end)

exports("NotifyLeftRank", function(title, subtitle, dict, icon, duration, color)
    PoggyNotification:NotifyLeftRank(tostring(title), tostring(subtitle), tostring(dict), tostring(icon), tonumber(duration), tostring(color or "COLOR_WHITE"))
end)

-- Get the notification class directly for advanced usage
exports("GetNotificationClass", function()
    return PoggyNotification
end)

-- Test command to verify NotifyLeft is working
RegisterCommand("testnotifyleft", function(source, args, rawCommand)
    print("^2[poggy_util]^7 Testing NotifyLeft...")
    PoggyNotification:NotifyLeft("TEST ALERT", "This is a test notification", "generic_textures", "tick", 5000, "COLOR_WHITE")
end, false)

print("^2[poggy_util]^7 Notifications module loaded successfully (use /testnotifyleft to test)")
