PoggyUtil = PoggyUtil or {}

-- Ensure client-side tables are initialized if not already
if IsDuplicityVersion() then -- Server side
    PoggyUtil.Utils = PoggyUtil.Utils or {}
    PoggyUtil.Player = PoggyUtil.Player or {}
else -- Client side
    PoggyUtil.Weapon = PoggyUtil.Weapon or {}
    PoggyUtil.WeaponJam = PoggyUtil.WeaponJam or {}
end

--==========================
--====== WEAPON EXPORTS ======
--==========================

--[[
    Retrieves the hash of the weapon currently equipped by the player.
    @returns number weaponHash - The hash of the current weapon, or WEAPON_UNARMED hash if none.

    Usage:
    local currentWepHash = exports["poggy_util"]:GetCurrentWeaponHash()
--]]
-- EXPORT MOVED TO: client/cl_weapon.lua
-- exports("GetCurrentWeaponHash", function()
--     if PoggyUtil.Weapon and PoggyUtil.Weapon.GetCurrentWeaponHash then
--         return PoggyUtil.Weapon.GetCurrentWeaponHash()
--     else
--         PoggyUtil.DebugClient.Error("EXPORTS", "GetCurrentWeaponHash called before PoggyUtil.Weapon was initialized.")
--         return GetHashKey("WEAPON_UNARMED") -- Fallback
--     end
-- end)

--[[
    Retrieves the entity ID of the weapon object currently equipped by the player.
    Useful for functions requiring a weapon entity, like GetWeaponDegradation.
    @returns Object weaponEntity - The entity ID of the current weapon object, or 0 if none or player invalid.

    Usage:
    local wepEntity = exports["poggy_util"]:GetCurrentWeaponEntity()
    if wepEntity ~= 0 then
        local degradation = GetWeaponDegradation(wepEntity)
    end
--]]
-- EXPORT MOVED TO: client/cl_weapon.lua
-- exports("GetCurrentWeaponEntity", function()
--     if PoggyUtil.Weapon and PoggyUtil.Weapon.GetCurrentWeaponEntity then
--         return PoggyUtil.Weapon.GetCurrentWeaponEntity()
--     else
--         PoggyUtil.DebugClient.Error("EXPORTS", "GetCurrentWeaponEntity called before PoggyUtil.Weapon was initialized.")
--         return 0 -- Fallback
--     end
-- end)


--================================
--====== WEAPON JAM EXPORTS ======
--================================

--[[
    Checks if a specific weapon hash is currently marked as jammed for the player.
    @param number weaponHash - The hash of the weapon to check.
    @returns boolean isJammed - True if the weapon is jammed, false otherwise.

    Usage:
    local pistolHash = GetHashKey("WEAPON_PISTOL_VOLCANIC")
    if exports["poggy_util"]:IsWeaponJammed(pistolHash) then
        -- Logic for when the volcanic pistol is jammed
    end
--]]
-- EXPORT MOVED TO: client/cl_weaponjam.lua
-- exports("IsWeaponJammed", function(weaponHash)
--     if PoggyUtil.WeaponJam and PoggyUtil.WeaponJam.IsWeaponJammed then
--         return PoggyUtil.WeaponJam.IsWeaponJammed(weaponHash)
--     end
--     PoggyUtil.DebugClient.Warning("EXPORTS", "IsWeaponJammed called before PoggyUtil.WeaponJam was initialized or for unknown hash %s.", weaponHash)
--     return false -- Default to not jammed if function not ready or weaponHash not found
-- end)

--=================================
--====== SERVER UTIL EXPORTS ======
--=================================

--[[
    (SERVER-SIDE)
    Retrieves the joaat hash of a given string.
    @param string str - The string to hash.
    @returns number hash - The joaat hash of the string, or 0 on error.

    Usage:
    local hash = exports["poggy_util"]:Joaat("WEAPON_REVOLVER_CATTLEMAN")
--]]
exports("Joaat", function(str)
    if IsDuplicityVersion() and PoggyUtil.Utils and PoggyUtil.Utils.Joaat then
        return PoggyUtil.Utils.Joaat(str)
    else
        if not IsDuplicityVersion() then
            -- This case should ideally not happen if exports are defined correctly in fxmanifest
            print("POGGY_UTIL_EXPORT_ERROR: Joaat is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "Joaat function not ready or PoggyUtil.Utils not initialized.")
        end
        return 0
    end
end)

--[[
    (SERVER-SIDE)
    Dumps a Lua table into a string representation, useful for debugging.
    @param table tbl - The table to dump.
    @returns string dumpedTable - A string representation of the table.

    Usage:
    local myTable = { a = 1, b = { c = "hello" } }
    local tableString = exports["poggy_util"]:DumpTable(myTable)
    print(tableString)
--]]
exports("DumpTable", function(tbl)
    if IsDuplicityVersion() and PoggyUtil.Utils and PoggyUtil.Utils.DumpTable then
        return PoggyUtil.Utils.DumpTable(tbl)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: DumpTable is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "DumpTable function not ready or PoggyUtil.Utils not initialized.")
        end
        return "Error: DumpTable not available or called on client."
    end
end)

--==================================
--====== SERVER PLAYER EXPORTS ======
--==================================

--[[
    (SERVER-SIDE)
    Retrieves VORP character information for a given player source.
    @param number source - The server ID of the player.
    @returns table characterInfo | nil - A table with character details 
                                       (charId, identifier, firstname, lastname, job, jobGrade, group)
                                       or nil if not found or error.

    Usage:
    local charInfo = exports["poggy_util"]:GetCharacterInfo(source)
    if charInfo then
        print("Player Job: " .. charInfo.job)
    end
--]]
exports("GetCharacterInfo", function(source)
    if IsDuplicityVersion() and PoggyUtil.Player and PoggyUtil.Player.GetCharacterInfo then
        return PoggyUtil.Player.GetCharacterInfo(source)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: GetCharacterInfo is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "GetCharacterInfo function not ready or PoggyUtil.Player not initialized.")
        end
        return nil
    end
end)

--=====================================
--====== OBJECT REMOVAL EXPORTS ======
--=====================================

--[[]
    (SERVER-SIDE)
    Removes objects with the specified model name from the server.
    @param string modelName - The model name of objects to remove.
    @returns number count - The number of objects that were removed.

    Usage:
    local count = exports["poggy_util"]:RemoveObjectsByModel("s_coachlock02x")
    print("Removed " .. count .. " coach locks")
--]]
exports("RemoveObjectsByModel", function(modelName)
    if IsDuplicityVersion() and PoggyUtil.ObjectRemoval and PoggyUtil.ObjectRemoval.RemoveObjectsByModel then
        return PoggyUtil.ObjectRemoval.RemoveObjectsByModel(modelName)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: RemoveObjectsByModel is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "RemoveObjectsByModel function not ready or PoggyUtil.ObjectRemoval not initialized.")
        end
        return 0
    end
end)

--[[]
    (SERVER-SIDE)
    Removes all objects configured in Config.ObjectRemoval.Objects
    @returns number count - The total number of objects that were removed.

    Usage:
    local totalRemoved = exports["poggy_util"]:RemoveConfiguredObjects()
    print("Removed " .. totalRemoved .. " objects in total.")
--]]
exports("RemoveConfiguredObjects", function()
    if IsDuplicityVersion() and PoggyUtil.ObjectRemoval and PoggyUtil.ObjectRemoval.RemoveConfiguredObjects then
        return PoggyUtil.ObjectRemoval.RemoveConfiguredObjects()
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: RemoveConfiguredObjects is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "RemoveConfiguredObjects function not ready or PoggyUtil.ObjectRemoval not initialized.")
        end
        return 0
    end
end)

--====================================
--====== DATABASE UTILITY EXPORTS ======
--====================================

--[[]
    (SERVER-SIDE)
    Execute a raw SQL query with parameters. Most flexible option for complex queries.
    @param string query - The SQL query to execute (use ? for parameters)
    @param table params - Array of parameters to bind to the query
    @param function callback - Optional callback function(result)
    @returns Promise|nil - Returns a promise if no callback provided

    Usage:
    -- With callback
    exports["poggy_util"]:ExecuteQuery(
        "SELECT * FROM users WHERE job = ? AND money > ?", 
        {"police", 1000}, 
        function(result)
            print("Found " .. #result .. " wealthy police officers")
        end
    )
    
    -- Synchronous (server only)
    local result = exports["poggy_util"]:ExecuteQuery("SELECT COUNT(*) as count FROM characters", {})
--]]
exports("ExecuteQuery", function(query, params, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.ExecuteQuery then
        return PoggyUtil.Database.ExecuteQuery(query, params, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: ExecuteQuery is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "ExecuteQuery function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(nil) end
        return nil
    end
end)

--[[]
    (SERVER-SIDE)
    Search for records with flexible WHERE conditions and options.
    @param string tableName - Name of the table to search
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param table options - Optional: {columns, orderBy, orderDirection, limit, offset}
    @param function callback - Callback function(results)

    Usage:
    -- Basic search
    exports["poggy_util"]:SearchRecords(
        "characters", 
        {job = "doctor", firstname = "John"}, 
        {},
        function(results)
            print("Found " .. #results .. " doctors named John")
        end
    )
    
    -- Advanced search with LIKE operator
    exports["poggy_util"]:SearchRecords(
        "characters",
        {
            firstname = {operator = "LIKE", value = "John%"},
            money = {operator = ">", value = 5000}
        },
        {
            columns = {"firstname", "lastname", "money"},
            orderBy = "money",
            orderDirection = "DESC",
            limit = 10
        },
        function(results)
            for _, char in ipairs(results) do
                print(char.firstname .. " " .. char.lastname .. " has $" .. char.money)
            end
        end
    )
--]]
exports("SearchRecords", function(tableName, whereConditions, options, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.SearchRecords then
        return PoggyUtil.Database.SearchRecords(tableName, whereConditions, options, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: SearchRecords is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "SearchRecords function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(nil) end
    end
end)

--[[]
    (SERVER-SIDE)
    Find character information by various criteria. Combines VORP integration with database search.
    @param table searchCriteria - Can include: source, charid, identifier, firstname, lastname, fullname
    @param function callback - Callback function(characterInfo)

    Usage:
    -- Find by server source
    exports["poggy_util"]:FindCharacter({source = playerId}, function(charInfo)
        if charInfo then
            print("Player name: " .. charInfo.firstname .. " " .. charInfo.lastname)
        end
    end)
    
    -- Find by character ID
    exports["poggy_util"]:FindCharacter({charid = "12345"}, function(charInfo)
        print("Found character: " .. (charInfo and charInfo.firstname or "Not found"))
    end)
    
    -- Find by name
    exports["poggy_util"]:FindCharacter({firstname = "John", lastname = "Doe"}, function(charInfo)
        -- Process character info
    end)
    
    -- Find by full name (will split into first and last)
    exports["poggy_util"]:FindCharacter({fullname = "John Doe"}, function(charInfo)
        -- Process character info
    end)
--]]
exports("FindCharacter", function(searchCriteria, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.FindCharacter then
        return PoggyUtil.Database.FindCharacter(searchCriteria, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: FindCharacter is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "FindCharacter function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(nil) end
    end
end)

--[[]
    (SERVER-SIDE)
    Insert a new record into any table.
    @param string tableName - Name of the table
    @param table data - Key-value pairs of column names and values
    @param function callback - Optional callback function(insertId)

    Usage:
    exports["poggy_util"]:InsertRecord(
        "custom_data",
        {
            player_id = 123,
            data_type = "achievement",
            data_value = "first_kill",
            timestamp = os.time()
        },
        function(insertId)
            print("Created record with ID: " .. (insertId or "failed"))
        end
    )
--]]
exports("InsertRecord", function(tableName, data, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.InsertRecord then
        return PoggyUtil.Database.InsertRecord(tableName, data, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: InsertRecord is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "InsertRecord function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(nil) end
    end
end)

--[[]
    (SERVER-SIDE)
    Update records in any table.
    @param string tableName - Name of the table
    @param table data - Key-value pairs of column names and values to update
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param function callback - Optional callback function(affectedRows)

    Usage:
    exports["poggy_util"]:UpdateRecord(
        "characters",
        {money = 10000, job = "police"},
        {charIdentifier = "12345"},
        function(affectedRows)
            print("Updated " .. affectedRows .. " characters")
        end
    )
--]]
exports("UpdateRecord", function(tableName, data, whereConditions, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.UpdateRecord then
        return PoggyUtil.Database.UpdateRecord(tableName, data, whereConditions, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: UpdateRecord is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "UpdateRecord function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(0) end
    end
end)

--[[]
    (SERVER-SIDE)
    Delete records from any table.
    @param string tableName - Name of the table
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param function callback - Optional callback function(affectedRows)

    Usage:
    exports["poggy_util"]:DeleteRecord(
        "old_logs",
        {created_at = {operator = "<", value = "2023-01-01"}},
        function(affectedRows)
            print("Deleted " .. affectedRows .. " old log entries")
        end
    )
--]]
exports("DeleteRecord", function(tableName, whereConditions, callback)
    if IsDuplicityVersion() and PoggyUtil.Database and PoggyUtil.Database.DeleteRecord then
        return PoggyUtil.Database.DeleteRecord(tableName, whereConditions, callback)
    else
        if not IsDuplicityVersion() then
            print("POGGY_UTIL_EXPORT_ERROR: DeleteRecord is a server-side export, called on client.")
        else
            PoggyUtil.DebugServer.Error("EXPORTS", "DeleteRecord function not ready or PoggyUtil.Database not initialized.")
        end
        if callback then callback(0) end
    end
end)
