PoggyUtil = PoggyUtil or {}
PoggyUtil.Utils = {}

-- Function to get the joaat hash of a string
-- Equivalent to GetHashKey
function PoggyUtil.Utils.Joaat(str)
    if type(str) ~= "string" then
        PoggyUtil.DebugServer.Error("UTILS", "Joaat: Input must be a string, got %s", type(str))
        return 0
    end
    local hash = GetHashKey(str)
    PoggyUtil.DebugServer.Trace("UTILS", "Joaat('%s') -> %s", str, hash)
    return hash
end

-- Function to dump a table to string for debugging
-- From: witnesses/server/core.lua
function PoggyUtil.Utils.DumpTable(o, indentLevel)
    if type(o) == 'table' then
        local s = '{\n'
        indentLevel = indentLevel or 0
        local indent = string.rep("  ", indentLevel + 1)
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. tostring(k) .. '"' end
            s = s .. indent .. '[' .. k .. '] = ' .. PoggyUtil.Utils.DumpTable(v, indentLevel + 1) .. ',\n'
        end
        return s .. string.rep("  ", indentLevel) .. '}'
    else
        return tostring(o)
    end
end
