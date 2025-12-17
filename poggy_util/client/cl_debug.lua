PoggyUtil = PoggyUtil or {}
PoggyUtil.DebugClient = {}

local function CanLog(category, level)
    if not Config or not Config.PoggyDebug or not Config.PoggyDebug.Enabled then return false end
    if not Config.PoggyDebug.Categories or not Config.PoggyDebug.Categories[category] then return false end
    if not Config.PoggyDebug.Level or not Config.PoggyDebug.Level[level] then return false end
    return true
end

function PoggyUtil.DebugClient.Log(category, level, message, ...)
    if not CanLog(category, level) then return end

    local formattedMessage = string.format(message, ...)
    local prefix = "^3[POGGY_UTIL_CLIENT:" .. string.upper(category) .. "]^7 "
    local levelColor = "^7" -- Default: white

    if level == "ERROR" then
        levelColor = "^1" -- Red
    elseif level == "WARNING" then
        levelColor = "^3" -- Yellow
    elseif level == "INFO" then
        levelColor = "^2" -- Green
    elseif level == "TRACE" then
        levelColor = "^5" -- Magenta/Blue (depends on console)
    end

    local logMessage = prefix .. levelColor .. "[" .. string.upper(level) .. "]^7 " .. formattedMessage

    if Config.PoggyDebug.LogToConsole then
        print(logMessage)
    end
end

function PoggyUtil.DebugClient.Trace(category, message, ...)
    PoggyUtil.DebugClient.Log(category, "TRACE", message, ...)
end

function PoggyUtil.DebugClient.Info(category, message, ...)
    PoggyUtil.DebugClient.Log(category, "INFO", message, ...)
end

function PoggyUtil.DebugClient.Warning(category, message, ...)
    PoggyUtil.DebugClient.Log(category, "WARNING", message, ...)
end

function PoggyUtil.DebugClient.Error(category, message, ...)
    PoggyUtil.DebugClient.Log(category, "ERROR", message, ...)
end

-- Initial check to ensure Config is loaded
Citizen.CreateThread(function()
    while Config == nil or Config.PoggyDebug == nil do
        print("[POGGY_UTIL_CLIENT:DEBUG] Waiting for Config.PoggyDebug to load...")
        Citizen.Wait(1000)
    end
    PoggyUtil.DebugClient.Info("CORE", "Client Debug Utility Initialized.")
end)

-- Advanced mount debugging utility

-- Register detailed debug command
RegisterCommand("mountdebug", function(source, args)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    print("^2===== MOUNT DEBUG REPORT =====^7")
    print("Player coords: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
    print("Player is on mount: " .. tostring(IsPedOnMount(ped)))
    
    -- Find nearby animals
    local itemSet = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords.x, coords.y, coords.z, 10.0, itemSet, 1)
    
    print("Found " .. size .. " peds nearby")
    
    if size > 0 then
        for i = 0, size - 1 do
            local entity = GetIndexedItemInItemset(i, itemSet)
            
            if DoesEntityExist(entity) and not IsPedHuman(entity) then
                local model = GetEntityModel(entity)
                local distance = #(coords - GetEntityCoords(entity))
                local canBeMounted = Citizen.InvokeNative(0x2D64376CF437363E, entity)
                local tamingState = Citizen.InvokeNative(0x454AD4DA6C41B5BD, entity)
                local isModelInConfig = false
                
                for _, modelName in ipairs(Config.MountableAnimals.Models) do
                    if model == GetHashKey(modelName) then
                        isModelInConfig = true
                        break
                    end
                end
                
                print(string.format("Animal #%d: Model=0x%X, Distance=%.2f, CanBeMounted=%s, TamingState=%d, InConfig=%s",
                    entity, model, distance, tostring(canBeMounted), tamingState or -1, tostring(isModelInConfig)))
            end
        end
    end
    
    if IsItemsetValid(itemSet) then
        DestroyItemset(itemSet)
    end
    
    print("^2===== END DEBUG REPORT =====^7")
end, false)

-- Direct mount command by entity ID
RegisterCommand("forcemount", function(source, args)
    if #args < 1 then
        print("Usage: /forcemount [entity_id]")
        return
    end
    
    local entityId = tonumber(args[1])
    if not entityId or not DoesEntityExist(entityId) then
        print("Invalid entity ID or entity doesn't exist")
        return
    end
    
    local ped = PlayerPedId()
    print("Attempting to force mount entity " .. entityId)
    
    -- Make entity permanently mountable
    SetEntityAsMissionEntity(entityId, true, true)
    SetBlockingOfNonTemporaryEvents(entityId, true)
    SetPedFleeAttributes(entityId, 0, false)
    Citizen.InvokeNative(0x1913FE4CBF41C463, entityId, 136, true) -- Can be mounted
    Citizen.InvokeNative(0x1913FE4CBF41C463, entityId, 297, true) -- Is mount
    Citizen.InvokeNative(0x1913FE4CBF41C463, entityId, 312, true) -- Is horse
    
    -- Set as player owned mount
    Citizen.InvokeNative(0xDBDB7792F82E1859, PlayerId(), entityId, true)
    
    -- Set taming state to mountable
    Citizen.InvokeNative(0x9FF1E042B9080C9B, entityId, 4)
    
    -- Force mount with warp
    TaskMountAnimal(ped, entityId, 100, -1, 1.0, 1, 0, 0)
    
    print("Force mount command issued")
end, false)

-- Spawn and mount a specific animal model
RegisterCommand("spawnmount", function(source, args)
    local modelName = "mp_a_c_moose_01"
    if #args > 0 then
        modelName = args[1]
    end
    
    local modelHash = GetHashKey(modelName)
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    
    print("Attempting to spawn and mount " .. modelName)
    
    -- Request the model
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 30 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(modelHash) then
        print("Failed to load model " .. modelName)
        return
    end
    
    -- Create the animal
    local animal = CreatePed(modelHash, coords.x, coords.y, coords.z, 0.0, true, false, false, false)
    
    if not DoesEntityExist(animal) then
        print("Failed to create animal")
        return
    end
    
    -- Make it mountable
    SetBlockingOfNonTemporaryEvents(animal, true)
    SetPedFleeAttributes(animal, 0, false)
    Citizen.InvokeNative(0x1913FE4CBF41C463, animal, 136, true) -- Can be mounted
    Citizen.InvokeNative(0x1913FE4CBF41C463, animal, 297, true) -- Is mount
    Citizen.InvokeNative(0x1913FE4CBF41C463, animal, 312, true) -- Is horse
    
    -- Set as player owned
    Citizen.InvokeNative(0xAEB97D84CDF3C00B, animal, 4)         -- Bonding level
    Citizen.InvokeNative(0xDF93973251FB2CA5, animal, true)      -- Security
    Citizen.InvokeNative(0xDBDB7792F82E1859, PlayerId(), animal, true)
    
    -- Set taming state
    Citizen.InvokeNative(0x9FF1E042B9080C9B, animal, 4)
    
    -- Mount it
    TaskMountAnimal(ped, animal, 5000, -1, 1.0, 1, 0, 0)
    
    print("Created animal entity " .. animal .. " - use /forcemount " .. animal .. " if needed")
end, false)

print("Mount debugging commands registered: /mountdebug, /forcemount, /spawnmount, /mountanimal")
