NAGE = exports['nage']:getSharedCode()

local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

------------------------------------------------------------------------------------------------------------------------

Citizen.SetTimeout(1000, function()
    if Config.Debug then
        NagePrint("warn", "^2Debug mode is enabled^7, this should only be used for testing & debugging purposes!")
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local nPlayer = NAGE.PlayerID(source)
    local identifiers = GetPlayerIdentifiers(nPlayer)
    local licenseId, discordId, fivemId

    for _, identifier in ipairs(identifiers) do
        if identifier:find("license:") then
            licenseId = identifier
        elseif identifier:find("discord:") then
            discordId = identifier
        elseif identifier:find("fivem:") then
            fivemId = identifier
        end
    end

    local column, value
    if discordId then
        column, value = "discord", discordId
    elseif fivemId then
        column, value = "fivem_id", fivemId
    elseif licenseId then
        column, value = "license", licenseId
    else
        return
    end

    local checkQuery = ("SELECT 1 FROM users WHERE %s = ? LIMIT 1"):format(column)
    exports.oxmysql:execute(checkQuery, {value}, function(result)
        if result and #result > 0 then
            if Config.Debug then
                NagePrint("info", "User %s (%s) already exists, skipping insert.", name, value)
            end
            return
        end
        
        local insertQuery = ("INSERT INTO users (%s, rank) VALUES (?, ?)"):format(column)
        exports.oxmysql:execute(insertQuery, {value, "owner"}, function()
            if Config.Debug then
                NagePrint("info", "Synced %s (%s) as owner in the database.", name, value)
            end
        end)
    end)
end)


RegisterNetEvent("nage:revivePlayer")
AddEventHandler("nage:revivePlayer", function(targetId)
    local nPlayer = NAGE.PlayerID(source)

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