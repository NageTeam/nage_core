NAGE = exports['nage']:getSharedCode()

local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
if not localeLoader then
    error("^4[Nage Core]^7 ^1[ERROR]^7: 'utils/locales.lua' could not be loaded in resource: " .. GetCurrentResourceName())
end
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

local function getTargetId(arg)
    if not arg then return nil end

    arg = tostring(arg)

    if arg:lower() == "me" then
        return NAGE.PlayerID()
    end

    local id = tonumber(arg)
    if id and NAGE.GetPlayerName(id) then
        return id
    end

    return nil
end

NAGE.RegisterCommand("clear", "Clear the current chat", function()
    TriggerEvent('chat:clear')
end)

NAGE.RegisterCommand("tpm", "Teleport to waypoint", function()
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        local waypointBlip = GetFirstBlipInfoId(GetWaypointBlipEnumId())
        if not DoesBlipExist(waypointBlip) then
            nage.notify({ title = locale["no_waypoint_found"], type = 'error' })
            return
        end

        local blipPos = GetBlipInfoIdCoord(waypointBlip)
        local z = GetHeightmapTopZForPosition(blipPos.x, blipPos.y)
        local _, groundZ = GetGroundZFor_3dCoord(blipPos.x, blipPos.y, z, true)

        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Citizen.Wait(50) end

        SetEntityCoords(NAGE.PlayerPedID(), blipPos.x, blipPos.y, z, true, false, false, false)
        FreezeEntityPosition(NAGE.PlayerPedID(), true)

        repeat
            Citizen.Wait(50)
            _, groundZ = GetGroundZFor_3dCoord(blipPos.x, blipPos.y, z, true)
        until groundZ ~= 0

        SetEntityCoords(NAGE.PlayerPedID(), blipPos.x, blipPos.y, groundZ + 1.0, true, false, false, false)
        FreezeEntityPosition(NAGE.PlayerPedID(), false)
        DoScreenFadeIn(500)
    end)
end, {
    { name = "ID", help = locale["target_id"] }
})

NAGE.RegisterCommand("goto", "Teleport to a player", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end
        
        local targetId = getTargetId(args[1])
        if not targetId or not NAGE.GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = 'error' })
            return
        end

        TriggerServerEvent("nage:gotoPlayer", targetId)
    end)
end, {
    { name = "ID", help = locale["target_id"] }
})

NAGE.RegisterCommand("bring", "Bring someone to you", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = getTargetId(args[1])
        if not targetId or not NAGE.GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = 'error' })
            return
        end

        TriggerServerEvent("nage:bringPlayer", targetId)
    end)
end, {
    { name = "ID", help = locale["target_id"] }
})

NAGE.RegisterCommand("revive", "Revive a player", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = getTargetId(args[1])
        if not targetId or not NAGE.GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = "error" })
            return
        end

        TriggerServerEvent("nage:revivePlayer", targetId)
    end)
end, {
    { name = "ID", help = locale["target_id"] }
})

NAGE.RegisterCommand("kill", "Kill a player", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = getTargetId(args[1])
        if not targetId or not NAGE.GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = "error" })
            return
        end

        TriggerServerEvent("nage:killPlayer", targetId)
    end)
end, {
    { name = "ID", help = locale["target_id"] }
})

NAGE.RegisterCommand("rank", "Check your rank", function()
    TriggerServerEvent("nage:requestRank")
end)

NAGE.RegisterCommand("setrank", "Set a player's rank", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 2 then
            nage.notify({
                title = 'Nage Core',
                description = locale["usage_setrank"],
                type = 'info'
            })
            return
        end
        
        local targetPlayer = tonumber(args[1])
        local rank = args[2]
        
        if not targetPlayer or not NAGE.GetPlayerName(targetPlayer) then
            nage.notify({ title = locale["invalid_player_id"], type = "error" })
            return
        end
        
        TriggerServerEvent('nage:updateRank', targetPlayer, rank)
    end)
end, {
    { name = "ID", help = locale["target_id"] },
    { name = "Rank", help = locale["new_rank"]}
})

NAGE.RegisterCommand("dv", "Delete the nearest or current vehicle", function()
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsIn(playerPed, false)

        if veh == 0 then
            local coords = GetEntityCoords(playerPed)
            local radius = 5.0
            veh = GetClosestVehicle(coords.x, coords.y, coords.z, radius, 0, 70)
        end

        if veh ~= 0 and DoesEntityExist(veh) then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
            if not DoesEntityExist(veh) then
                nage.notify({
                    title = 'Nage Core',
                    description = locale["vehicle_deleted"],
                    type = 'success'
                })
            else
                nage.notify({
                    title = 'Nage Core',
                    description = locale["vehicle_delete_error"],
                    type = 'success'
                })
            end
        else
            nage.notify({
                title = 'Nage Core',
                description = locale["no_vehicles"],
                type = 'success'
            })
        end
    end)
end)

NAGE.RegisterCommand("car", "Spawn a vehicle by name or hash", function(_, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({
                title = 'Nage Core',
                description = locale["usage_car"],
                type = 'info'
            })
            return
        end

        local modelInput = args[1]
        local model

        if string.sub(modelInput, 1, 2) == "0x" then
            model = tonumber(modelInput)
        elseif tonumber(modelInput) then
            model = tonumber(modelInput)
        else
            model = GetHashKey(modelInput)
        end

        if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
            nage.notify({
                title = 'Nage Core',
                description = locale["invalid_model"],
                type = 'error'
            })
            return
        end

        RequestModel(model)
        local start = GetGameTimer()
        while not HasModelLoaded(model) do
            Wait(10)
            if GetGameTimer() - start > 5000 then
                nage.notify({
                    title = 'Nage Core',
                    description = locale["failed_vehicle"],
                    type = 'error'
                })
                return
            end
        end

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)

        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        SetPedIntoVehicle(playerPed, veh, -1)
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleNumberPlateText(veh, "NAGE")
        SetVehicleFuelLevel(veh, 100.0)
        SetModelAsNoLongerNeeded(model)

        SetVehicleModKit(veh, 0)
        SetVehicleMod(veh, 11, 3, false) -- Engine level 4
        SetVehicleMod(veh, 12, 3, false) -- Brakes level 4
        SetVehicleMod(veh, 13, 3, false) -- Transmission level 4
        SetVehicleMod(veh, 15, 3, false) -- Suspension level 4
        SetVehicleMod(veh, 16, 4, false) -- Armor level 5
        ToggleVehicleMod(veh, 18, true)  -- Turbo on

        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)

        local displayName = GetDisplayNameFromVehicleModel(model)
        if displayName and displayName ~= "CARNOTFOUND" then
            displayName = string.upper(GetLabelText(displayName)) or displayName
        else
            displayName = tostring(modelInput)
        end

        nage.notify({
            title = 'Nage Core',
            description = string.format(locale["spawned_vehicle"], displayName),
            type = 'info'
        })
    end)
end, {
    { name = "Vehicle", help = locale["model_or_hash"] }
})

RegisterNetEvent("nage:receiveRank")
AddEventHandler("nage:receiveRank", function(rank)
    TriggerEvent('chat:addMessage', { args = { "^2Your Rank", rank } })
    nage.notify({
        title = 'Nage Core',
        description = string.format(locale["your_rank_desc"], rank),
        type = 'info'
    })
end)

RegisterNetEvent("nage:teleportToCoords")
AddEventHandler("nage:teleportToCoords", function(coords)
    SetEntityCoords(NAGE.PlayerPedID(), coords.x, coords.y, coords.z, false, false, false, false)
end)

RegisterNetEvent('nage:revivePlayer')
AddEventHandler('nage:revivePlayer', function()
    local ped = NAGE.PlayerPedID()

    if IsEntityDead(ped) then
        local coords = GetEntityCoords(ped)

        ResurrectPed(ped)
        ClearPedTasksImmediately(ped)
        ClearPedBloodDamage(ped)
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
        SetEntityHealth(ped, 200)

        nage.notify({
            title = 'Nage Core',
            description = locale["revived_by_admin"] or locale["you_are_not_dead"],
            type = 'success',
            icon = 'fa-solid fa-heart-pulse'
        })
    else
        nage.notify({
            title = 'Nage Core',
            description = locale["you_are_not_dead"],
            type = 'error',
            icon = 'fa-solid fa-heart'
        })
    end
end)

RegisterNetEvent("nage:killPlayer")
AddEventHandler("nage:killPlayer", function()
    local ped = NAGE.PlayerPedID()
    SetEntityHealth(ped, 0)
end)
