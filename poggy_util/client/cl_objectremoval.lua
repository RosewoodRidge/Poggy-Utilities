PoggyUtil = PoggyUtil or {}
PoggyUtil.ObjectRemoval = {}

-- Event handler for object removal requests from server
RegisterNetEvent("poggy_util:findAndRemoveByModel")
AddEventHandler("poggy_util:findAndRemoveByModel", function(modelName)
    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Received request to remove all objects with model: %s", modelName)

    local modelHash = GetHashKey(modelName)
    if modelHash == 0 then
        PoggyUtil.DebugClient.Warning("OBJECT_REMOVAL", "Could not find hash for model: %s", modelName)
        return
    end

    local objects = GetGamePool('CObject')
    local deletedCount = 0

    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Searching through %d objects in pool for hash %s", #objects, modelHash)

    -- Process each object
    for i, obj in ipairs(objects) do
        if DoesEntityExist(obj) and GetEntityModel(obj) == modelHash then
            PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Found matching object (Entity ID: %d). Attempting delete.", obj)

            -- Set as mission entity to allow deletion
            SetEntityAsMissionEntity(obj, true, true)

            -- Attempt to delete the object
            if DeleteObject(obj) or DeleteEntity(obj) then
                deletedCount = deletedCount + 1
            else
                PoggyUtil.DebugClient.Error("OBJECT_REMOVAL", "Failed to delete object (Entity ID: %d).", obj)
            end
        end

        -- Add a small wait to prevent client freezes if there are many objects
        if i % 25 == 0 then
            Citizen.Wait(1)
        end
    end

    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Finished search for model '%s'. Deleted %d object(s).", modelName, deletedCount)
end)

-- Event handler for dead entity cleanup requests from server
RegisterNetEvent("poggy_util:cleanupDeadEntities")
AddEventHandler("poggy_util:cleanupDeadEntities", function(options)
    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Received dead entity cleanup request")
    
    local deletedPeds = 0
    local deletedHorses = 0
    local deletedAnimals = 0
    local deletedWagons = 0
    
    local peds = GetGamePool('CPed')
    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Scanning %d peds for dead entities", #peds)
    
    local playerPed = PlayerPedId()
    
    for i, ped in ipairs(peds) do
        if DoesEntityExist(ped) and IsEntityDead(ped) and ped ~= playerPed then
            -- Skip player peds
            if not IsPedAPlayer(ped) then
                local isHorse = false
                local isAnimal = false
                
                -- Check if it's a horse or mount
                if Citizen.InvokeNative(0x772A1969F649E902, ped) then -- IS_PED_ON_MOUNT or similar horse check
                    isHorse = true
                elseif Citizen.InvokeNative(0x9FF1E042FA597187, ped) then -- _IS_THIS_MODEL_A_HORSE
                    isHorse = true
                else
                    -- Alternative: Check common horse model hashes
                    local model = GetEntityModel(ped)
                    -- Use native to check if ped is human
                    local isHuman = Citizen.InvokeNative(0xB980061DA992779D, ped) -- IS_PED_HUMAN
                    if not isHuman then
                        -- It's an animal - determine if horse or other
                        -- Horses are typically mounts
                        if IsPedOnMount(ped) or GetMount(ped) ~= 0 then
                            isHorse = true
                        else
                            isAnimal = true
                        end
                    end
                end
                
                -- More reliable animal/horse detection
                local isHuman = Citizen.InvokeNative(0xB980061DA992779D, ped) -- IS_PED_HUMAN
                if not isHuman then
                    -- Check if this is a horse using model relationship
                    local pedType = GetPedType(ped)
                    -- Ped type 28 is typically horses in RDR2
                    if pedType == 28 then
                        isHorse = true
                        isAnimal = false
                    else
                        isAnimal = true
                        isHorse = false
                    end
                end
                
                local shouldDelete = false
                
                if isHorse and options.cleanHorses then
                    shouldDelete = true
                    deletedHorses = deletedHorses + 1
                    PoggyUtil.DebugClient.Trace("OBJECT_REMOVAL", "Found dead horse (Entity ID: %d)", ped)
                elseif isAnimal and options.cleanAnimals then
                    shouldDelete = true
                    deletedAnimals = deletedAnimals + 1
                    PoggyUtil.DebugClient.Trace("OBJECT_REMOVAL", "Found dead animal (Entity ID: %d)", ped)
                elseif not isHorse and not isAnimal and options.cleanPeds then
                    shouldDelete = true
                    deletedPeds = deletedPeds + 1
                    PoggyUtil.DebugClient.Trace("OBJECT_REMOVAL", "Found dead NPC (Entity ID: %d)", ped)
                end
                
                if shouldDelete then
                    SetEntityAsMissionEntity(ped, true, true)
                    DeletePed(ped)
                    if DoesEntityExist(ped) then
                        DeleteEntity(ped)
                    end
                end
            end
        end
        
        -- Prevent client freeze
        if i % 50 == 0 then
            Citizen.Wait(1)
        end
    end
    
    -- Clean up dead wagons/vehicles
    if options.cleanWagons then
        local vehicles = GetGamePool('CVehicle')
        PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Scanning %d vehicles for dead wagons", #vehicles)

        for i, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) and IsEntityDead(vehicle) then
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
                if DoesEntityExist(vehicle) then
                    DeleteEntity(vehicle)
                end
                deletedWagons = deletedWagons + 1
                PoggyUtil.DebugClient.Trace("OBJECT_REMOVAL", "Found dead wagon/vehicle (Entity ID: %d)", vehicle)
            end

            if i % 50 == 0 then
                Citizen.Wait(1)
            end
        end
    end

    local totalDeleted = deletedPeds + deletedHorses + deletedAnimals + deletedWagons
    PoggyUtil.DebugClient.Info("OBJECT_REMOVAL", "Dead entity cleanup complete. Deleted: %d NPCs, %d horses, %d animals, %d wagons (Total: %d)", 
        deletedPeds, deletedHorses, deletedAnimals, deletedWagons, totalDeleted)
end)

PoggyUtil.DebugClient.Info("CORE", "Object Removal Client Initialized.")