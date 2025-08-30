local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

RegisterNetEvent("nage:revivePlayer")
AddEventHandler("nage:revivePlayer", function(targetId)
    local nPlayer = NAGE.PlayerID(source)

    if not NAGE or not NAGE.TriggerCallback then
        NagePrint("error", "TriggerCallback is not defined.")
        return
    end

    NAGE.TriggerCallback("nage:checkAdminAccess", nPlayer, function(isAdmin)
        if not isAdmin then
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["not_admin"],
                type = 'error'
            })
            return
        end

        if not targetId or not GetPlayerName(targetId) then
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["invalid_player_id"],
                type = 'error'
            })
            return
        end

        TriggerClientEvent('nage:revivePlayer', targetId)
        TriggerClientEvent('nage_notify:notify', nPlayer, {
            title = locale["player_revived"],
            type = 'info'
        })
    end)
end)

RegisterNetEvent("nage:killPlayer")
AddEventHandler("nage:killPlayer", function(targetId)
    local nPlayer = NAGE.PlayerID(source)

    if not NAGE or not NAGE.TriggerCallback then
        NagePrint("error", "TriggerCallback is not defined.")
        return
    end

    NAGE.TriggerCallback("nage:checkAdminAccess", nPlayer, function(isAdmin)
        if not isAdmin then
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["not_admin"],
                type = 'error'
            })
            return
        end

        if not targetId or not GetPlayerName(targetId) then
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["invalid_player_id"],
                type = 'error'
            })
            return
        end

        TriggerClientEvent('nage:killPlayer', targetId)
        TriggerClientEvent('nage_notify:notify', nPlayer, {
            title = locale["player_killed"],
            type = 'info'
        })
    end)
end)

RegisterNetEvent("nage:criticalKill:requestKill")
AddEventHandler("nage:criticalKill:requestKill", function(victimId)
    local attackerId = source

    if not NAGE or not NAGE.TriggerCallback then
        NagePrint("error", "TriggerCallback is not defined.")
        return
    end

    NAGE.TriggerCallback("nage:checkAdminAccess", attackerId, function(isAdmin)
        if not isAdmin then
            TriggerClientEvent('nage_notify:notify', attackerId, {
                title = locale["not_admin"],
                type = 'error'
            })
            return
        end

        if GetPlayerPing(victimId) > 0 then
            TriggerClientEvent("nage:criticalKill:forceKill", victimId)
        end
    end)
end)
