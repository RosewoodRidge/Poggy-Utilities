PoggyUtil = PoggyUtil or {}
PoggyUtil.Database = {}

-- Wait for dependencies
Citizen.CreateThread(function()
    while PoggyUtil.DebugServer == nil do
        Citizen.Wait(100)
    end
    PoggyUtil.DebugServer.Info("DATABASE", "Database utility initialized.")
end)

--[[
    Execute a raw SQL query with parameters
    @param string query - The SQL query to execute
    @param table params - Array of parameters to bind to the query
    @param function callback - Optional callback function(result)
    @returns Promise|nil - Returns a promise if no callback provided
]]
function PoggyUtil.Database.ExecuteQuery(query, params, callback)
    if not query or type(query) ~= "string" then
        PoggyUtil.DebugServer.Error("DATABASE", "ExecuteQuery: Invalid query provided")
        if callback then callback(nil) end
        return
    end
    
    params = params or {}
    
    PoggyUtil.DebugServer.Trace("DATABASE", "ExecuteQuery: %s with %d parameters", query, #params)
    
    if callback then
        exports.oxmysql:execute(query, params, function(result)
            PoggyUtil.DebugServer.Trace("DATABASE", "Query completed, result type: %s", type(result))
            callback(result)
        end)
    else
        -- Corrected line
        return exports.oxmysql:query(query, params)
    end
end

--[[
    Search for records with flexible WHERE conditions
    @param string tableName - Name of the table to search
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param table options - Optional: columns, orderBy, limit, offset
    @param function callback - Optional callback function(results)
]]
-- File: poggy_util/server/sv_database.lua

function PoggyUtil.Database.SearchRecords(tableName, whereConditions, options, callback)
    if not tableName or type(tableName) ~= "string" then
        PoggyUtil.DebugServer.Error("DATABASE", "SearchRecords: Invalid table name")
        if callback then callback(nil) end
        return
    end
    
    whereConditions = whereConditions or {}
    options = options or {}
    
    -- Build SELECT clause
    local columns = options.columns or "*"
    if type(columns) == "table" then
        columns = table.concat(columns, ", ")
    end
    
    -- Build WHERE clause
    local whereClause = ""
    local params = {}
    
    if next(whereConditions) then
        local conditions = {}
        for column, value in pairs(whereConditions) do
            if type(value) == "table" and value.operator then
                -- Advanced condition: {operator = "LIKE", value = "%search%"}
                table.insert(conditions, column .. " " .. value.operator .. " ?")
                table.insert(params, value.value)
            else
                -- Simple equality condition
                table.insert(conditions, column .. " = ?")
                table.insert(params, value)
            end
        end
        whereClause = " WHERE " .. table.concat(conditions, " AND ")
    end
    
    -- Build ORDER BY clause
    local orderClause = ""
    if options.orderBy then
        orderClause = " ORDER BY " .. options.orderBy
        if options.orderDirection then
            orderClause = orderClause .. " " .. options.orderDirection
        end
    end
    
    -- Build LIMIT clause
    local limitClause = ""
    if options.limit then
        limitClause = " LIMIT " .. tonumber(options.limit)
        if options.offset then
            limitClause = limitClause .. " OFFSET " .. tonumber(options.offset)
        end
    end
    
    local query = "SELECT " .. columns .. " FROM " .. tableName .. whereClause .. orderClause .. limitClause
    
    PoggyUtil.DebugServer.Trace("DATABASE", "SearchRecords query: %s", query)
    
    -- FIX: Return the result of ExecuteQuery to handle synchronous calls correctly.
    return PoggyUtil.Database.ExecuteQuery(query, params, callback)
end

--[[
    Find character information by various criteria
    @param table searchCriteria - Can include: source, charid, identifier, firstname, lastname, fullname
    @param function callback - Callback function(characterInfo)
]]
function PoggyUtil.Database.FindCharacter(searchCriteria, callback)
    if not searchCriteria or not next(searchCriteria) then
        PoggyUtil.DebugServer.Error("DATABASE", "FindCharacter: No search criteria provided")
        if callback then callback(nil) end
        return
    end
    
    -- If searching by source (server ID), use VORP first
    if searchCriteria.source then
        local charInfo = PoggyUtil.Player.GetCharacterInfo(searchCriteria.source)
        if charInfo and callback then
            callback(charInfo)
            return
        end
    end
    
    -- Build database search conditions
    local whereConditions = {}
    
    if searchCriteria.charid then
        whereConditions.charIdentifier = searchCriteria.charid
    end
    
    if searchCriteria.identifier then
        whereConditions.identifier = searchCriteria.identifier
    end
    
    if searchCriteria.firstname then
        whereConditions.firstname = searchCriteria.firstname
    end
    
    if searchCriteria.lastname then
        whereConditions.lastname = searchCriteria.lastname
    end
    
    if searchCriteria.fullname then
        -- Split fullname into first and last
        local nameParts = {}
        for word in searchCriteria.fullname:gmatch("%S+") do
            table.insert(nameParts, word)
        end
        if #nameParts >= 2 then
            whereConditions.firstname = nameParts[1]
            whereConditions.lastname = nameParts[2]
        end
    end
    
    PoggyUtil.Database.SearchRecords("characters", whereConditions, {limit = 1}, function(results)
        if results and #results > 0 then
            if callback then callback(results[1]) end
        else
            PoggyUtil.DebugServer.Warning("DATABASE", "FindCharacter: No character found with criteria")
            if callback then callback(nil) end
        end
    end)
end

--[[
    Generic insert function
    @param string tableName - Name of the table
    @param table data - Key-value pairs of column names and values
    @param function callback - Optional callback function(insertId)
]]
function PoggyUtil.Database.InsertRecord(tableName, data, callback)
    if not tableName or not data or not next(data) then
        PoggyUtil.DebugServer.Error("DATABASE", "InsertRecord: Invalid parameters")
        if callback then callback(nil) end
        return
    end
    
    local columns = {}
    local placeholders = {}
    local params = {}
    
    for column, value in pairs(data) do
        table.insert(columns, column)
        table.insert(placeholders, "?")
        table.insert(params, value)
    end
    
    local query = "INSERT INTO " .. tableName .. " (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(placeholders, ", ") .. ")"
    
    PoggyUtil.Database.ExecuteQuery(query, params, function(result)
        if callback then
            callback(result and result.insertId or nil)
        end
    end)
end

--[[
    Generic update function
    @param string tableName - Name of the table
    @param table data - Key-value pairs of column names and values to update
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param function callback - Optional callback function(affectedRows)
]]
function PoggyUtil.Database.UpdateRecord(tableName, data, whereConditions, callback)
    if not tableName or not data or not next(data) or not whereConditions or not next(whereConditions) then
        PoggyUtil.DebugServer.Error("DATABASE", "UpdateRecord: Invalid parameters")
        if callback then callback(0) end
        return
    end
    
    local setClauses = {}
    local params = {}
    
    -- Build SET clause
    for column, value in pairs(data) do
        table.insert(setClauses, column .. " = ?")
        table.insert(params, value)
    end
    
    -- Build WHERE clause
    local whereClauses = {}
    for column, value in pairs(whereConditions) do
        table.insert(whereClauses, column .. " = ?")
        table.insert(params, value)
    end
    
    local query = "UPDATE " .. tableName .. " SET " .. table.concat(setClauses, ", ") .. " WHERE " .. table.concat(whereClauses, " AND ")
    
    PoggyUtil.Database.ExecuteQuery(query, params, function(result)
        if callback then
            callback(result and result.affectedRows or 0)
        end
    end)
end

--[[
    Generic delete function
    @param string tableName - Name of the table
    @param table whereConditions - Key-value pairs for WHERE conditions
    @param function callback - Optional callback function(affectedRows)
]]
function PoggyUtil.Database.DeleteRecord(tableName, whereConditions, callback)
    if not tableName or not whereConditions or not next(whereConditions) then
        PoggyUtil.DebugServer.Error("DATABASE", "DeleteRecord: Invalid parameters")
        if callback then callback(0) end
        return
    end
    
    local whereClauses = {}
    local params = {}
    
    for column, value in pairs(whereConditions) do
        table.insert(whereClauses, column .. " = ?")
        table.insert(params, value)
    end
    
    local query = "DELETE FROM " .. tableName .. " WHERE " .. table.concat(whereClauses, " AND ")
    
    PoggyUtil.Database.ExecuteQuery(query, params, function(result)
        if callback then
            callback(result and result.affectedRows or 0)
        end
    end)
end
