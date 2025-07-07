NAGE = exports['nage']:getSharedCode()
local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
if not localeLoader then
    error("^4[Nage Core]^7 ^1[ERROR]^7: 'utils/locales.lua' could not be loaded in resource: " .. GetCurrentResourceName())
end
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")
RegisterCommand("clear", function()
    TriggerEvent('chat:clear')
end, false)

RegisterCommand("tpm", function()
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
end, false)

RegisterCommand("goto", function(source, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = 'error' })
            return
        end

        TriggerServerEvent("nage:gotoPlayer", targetId)
    end)
end, false)

RegisterCommand("bring", function(source, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = 'error' })
            return
        end

        TriggerServerEvent("nage:bringPlayer", targetId)
    end)
end, false)

RegisterCommand("revive", function(source, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = "error" })
            return
        end

        TriggerServerEvent("nage:revivePlayer", targetId)
    end)
end, false)

RegisterCommand("kill", function(source, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 1 then
            nage.notify({ title = "Nage Core", description = locale["must_provide_id"], type = "error" })
            return
        end

        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerName(targetId) then
            nage.notify({ title = locale["invalid_player_id"], type = "error" })
            return
        end

        TriggerServerEvent("nage:killPlayer", targetId)
    end)
end, false)

RegisterCommand("rank", function()
    TriggerServerEvent("nage:requestRank")
end, false)

RegisterCommand("setrank", function(source, args)
    NAGE.TriggerServerCallback("nage:checkAdminAccess", function(isAdmin)
        if not isAdmin then
            nage.notify({ title = locale["not_admin"], type = 'error' })
            return
        end

        if #args < 2 then
            print(locale["usage_setrank"])
            return
        end
        
        local targetPlayer = tonumber(args[1])
        local rank = args[2]
        
        if not targetPlayer or not GetPlayerName(targetPlayer) then
            print(locale["invalid_player_id"])
            return
        end
        
        TriggerServerEvent('nage:updateRank', targetPlayer, rank)
    end)
end, false)

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
            description = locale["revived_by_admin"],
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

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/clear', 'Clear the current chat',{})
    TriggerEvent('chat:addSuggestion', '/tpm', 'Teleport to waypoint',{})
    TriggerEvent('chat:addSuggestion', '/goto', 'TP to a player',{{name="ID", help=locale["arg_target_id"] or "Put target ID here"}})
    TriggerEvent('chat:addSuggestion', '/bring', 'Bring someone to you',{{name="ID", help=locale["arg_target_id"] or "Put target ID here"}})
    TriggerEvent('chat:addSuggestion', '/revive', 'Revive a player',{{name="ID", help=locale["arg_target_id"] or "Put target ID here"}})
    TriggerEvent('chat:addSuggestion', '/rank', 'Check your rank',{})
    TriggerEvent('chat:addSuggestion', '/setrank', 'Set a player rank',{{name="ID", help=locale["arg_target_id"] or "Put target ID here"}, {name="Rank", help=locale["arg_rank"] or "Put the new rank"}})
    TriggerEvent('chat:addSuggestion', '/kill', 'Kill a player',{{name="ID", help=locale["arg_target_id"] or "Put target ID here"}})
end)
