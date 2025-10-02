local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")
NAGE = exports['nage']:getSharedCode()

RegisterNetEvent("nage:requestRank")
AddEventHandler("nage:requestRank", function()
    local nPlayer = NAGE.PlayerID(source)
    local license

    for i = 0, GetNumPlayerIdentifiers(nPlayer) - 1 do
        local id = GetPlayerIdentifier(nPlayer, i)
        if string.sub(id, 1, 7) == "license" then
            license = id:sub(9)
            break
        end
    end

    if not license then
        NagePrint("error", locale["no_license_found"])
        return
    end

    exports.oxmysql:query('SELECT rank FROM users WHERE license = ?', {license}, function(result)
        if result and result[1] then
            TriggerClientEvent("nage:receiveRank", nPlayer, result[1].rank)
        else
            TriggerClientEvent("nage:receiveRankError", nPlayer, locale["rank_not_found_db"])
        end
    end)
end)

RegisterNetEvent('nage:updateRank')
AddEventHandler('nage:updateRank', function(nPlayer, newRank)
    local nPlayer = NAGE.PlayerID(source)

    NAGE.TriggerCallback("nage:checkAdminAccess", nPlayer, function(isAdmin)
        if not isAdmin then
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["not_admin"],
                type = 'error'
            })
            return
        end
        local allowed = false
        for _, rank in ipairs(Config.Ranks.Ranks) do
            if rank == newRank then
                allowed = true
                break
            end
        end
    
        if not allowed then
            NagePrint("error", locale["invalid_rank_attempt"], tostring(newRank))
            TriggerClientEvent('nage_notify:notify', nPlayer, {
                title = locale["invalid_rank_notify"]:format(newRank),
                type = 'error'
            })
            return
        end
    
        local license
        for i = 0, GetNumPlayerIdentifiers(nPlayer) - 1 do
            local id = GetPlayerIdentifier(nPlayer, i)
            if string.sub(id, 1, 7) == "license" then
                license = id:sub(9)
                break
            end
        end
    
        if not license then
            NagePrint("error", locale["no_license_found"])
            return
        end
    
        exports.oxmysql:query('SELECT rank FROM users WHERE license = ?', {license}, function(result)
            if result and result[1] then
                local oldRank = result[1].rank
    
                exports.oxmysql:execute('UPDATE users SET rank = ? WHERE license = ?', {newRank, license}, function(result)
                    if result and result.affectedRows and result.affectedRows > 0 then
                        NagePrint("info", locale["rank_updated"]:format(GetPlayerName(nPlayer), oldRank, newRank))
                        TriggerEvent('nage:updatedRank', nPlayer, newRank)
                    else
                        NagePrint("info", locale["no_rank_updated"]:format(GetPlayerName(nPlayer)))
                    end
                end)
            else
                NagePrint("error", locale["player_not_found_db"], GetPlayerName(nPlayer))
            end
        end)
    end)
end)
