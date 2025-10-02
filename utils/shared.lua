NAGE = NAGE or {}
local oxmysql = exports.oxmysql
NAGE.Commands = {}

function NAGE.RegisterCommand(name, description, cb, args)
    if not name or not cb then
        return NagePrint("error", "Invalid command registration for %s", name or "nil")
    end

    NAGE.Commands[name] = {
        description = description or "No description",
        handler = cb,
        args = args or {}
    }

    Citizen.CreateThread(function()
        TriggerEvent('chat:addSuggestion', '/' .. name, description or "", args or {})
    end)

    if IsDuplicityVersion() then
        RegisterCommand(name, function(source, cmdArgs, rawCommand)
            cb(source, cmdArgs, rawCommand)
        end, false)
    else
        RegisterCommand(name, function(_, cmdArgs, rawCommand)
            cb(NAGE.PlayerID(), cmdArgs, rawCommand)
        end, false)
    end

    if Config.Debug then
        NagePrint("debug", "Registered command: %s (%s)", name, description or "")
    end
end

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
            if identifier and identifier:find("license:") then
                return identifier:gsub("license:", "")
            end
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
        local license = NAGE.GetIdentifier(nPlayer)
        if not license then return cb(nil) end
    
        oxmysql:query('SELECT money FROM users WHERE license = ?', { license }, function(result)
            if result and result[1] then
                cb(tonumber(result[1].money))
            else
                cb(0)
            end
        end)
    end
    
    NAGE.AddMoney = function(nPlayer, amount, cb)
        local license = NAGE.GetIdentifier(nPlayer)
        if not license then return cb and cb(false) end
    
        oxmysql:update('UPDATE users SET money = money + ? WHERE license = ?', { amount, license }, function(affectedRows)
            if cb then cb(affectedRows > 0) end
        end)
    end
    
    NAGE.RemoveMoney = function(nPlayer, amount, cb)
        local license = NAGE.GetIdentifier(nPlayer)
        if not license then return cb and cb(false) end
    
        NAGE.GetMoney(nPlayer, function(balance)
            if not balance or balance < amount then
                if cb then cb(false, "not_enough") end
                return
            end
    
            oxmysql:update('UPDATE users SET money = money - ? WHERE license = ?', { amount, license }, function(affectedRows)
                if cb then cb(affectedRows > 0) end
            end)
        end)
    end
    
    NAGE.SetMoney = function(nPlayer, amount, cb)
        local license = NAGE.GetIdentifier(nPlayer)
        if not license then return cb and cb(false) end
    
        oxmysql:update('UPDATE users SET money = ? WHERE license = ?', { amount, license }, function(affectedRows)
            if cb then cb(affectedRows > 0) end
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

        oxmysql:query('SELECT * FROM users WHERE license LIKE ?', { license }, function(result)
            if result and result[1] then
                cb(result[1])
            else
                cb(nil)
            end
        end)
    end
else
    NAGE.PlayerID = function()
        return GetPlayerServerId(PlayerId())
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

function NAGE.GetCommands()
    return NAGE.Commands
end

exports('getSharedCode', function()
    return NAGE
end)
