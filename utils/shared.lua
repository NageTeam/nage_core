NAGE = NAGE or {}
local oxmysql = exports.oxmysql

if IsDuplicityVersion() then
    NAGE.PlayerID = function(nPlayer)
        return nPlayer or -1
    end

    NAGE.GetPlayerName = function(nPlayer)
        return GetPlayerName(nPlayer)
    end

    NAGE.GetIdentifier = function(nPlayer)
        for i = 0, GetNumPlayerIdentifiers(nPlayer) - 1 do
            local identifier = GetPlayerIdentifier(nPlayer, i)
            if identifier then return identifier end
        end
        return nil
    end

    NAGE.GetHealth = function(nPlayer)
        local ped = GetPlayerPed(nPlayer)
        return GetEntityHealth(ped)
    end

    NAGE.GetArmor = function(nPlayer)
        local ped = GetPlayerPed(nPlayer)
        return GetPedArmour(ped)
    end

    NAGE.GetCoords = function(nPlayer)
        local ped = GetPlayerPed(nPlayer)
        local coords = GetEntityCoords(ped)
        return vector3(coords.x, coords.y, coords.z)
    end

    NAGE.GetMoney = function(nPlayer, cb)
        local identifier = NAGE.GetIdentifier(nPlayer)
        if not identifier then
            cb(nil)
            return
        end

        oxmysql:query('SELECT money FROM users WHERE identifier = ?', { identifier }, function(result)
            if result and result[1] then
                cb(result[1].money)
            else
                cb(nil)
            end
        end)
    end

    NAGE.Teleport = function(nPlayer, coords)
        local ped = GetPlayerPed(nPlayer)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    end

    NAGE.PlayerData = function(license, cb)
        if not license then
            cb(nil)
            return
        end

        oxmysql:query('SELECT * FROM users WHERE identifier LIKE ?', { license }, function(result)
            if result and result[1] then
                cb(result[1])
            else
                cb(nil)
            end
        end)
    end
else
    NAGE.PlayerID = function()
        return PlayerId()
    end

    NAGE.PlayerPedID = function()
        return PlayerPedId()
    end

    NAGE.GetPlayerName = function()
        return GetPlayerName(PlayerId())
    end

    NAGE.GetHealth = function()
        return GetEntityHealth(PlayerPedId())
    end

    NAGE.GetArmor = function()
        return GetPedArmour(PlayerPedId())
    end

    NAGE.GetCoords = function()
        local coords = GetEntityCoords(PlayerPedId())
        return vector3(coords.x, coords.y, coords.z)
    end
end

exports('getSharedCode', function()
    return NAGE
end)
