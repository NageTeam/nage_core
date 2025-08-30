local NAGE = exports['nage']:getSharedCode()

local players = {}

local function formatTime(totalMinutes)
    local days = math.floor(totalMinutes / 1440)
    local hours = math.floor((totalMinutes % 1440) / 60)
    local minutes = totalMinutes % 60
    local parts = {}
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 then table.insert(parts, hours .. "h") end
    table.insert(parts, minutes .. "m")
    return table.concat(parts, " ")
end

local function getLicense(id)
    for _, id in ipairs(GetPlayerIdentifiers(id)) do
        if id:sub(1,7) == "license" then
            return id:sub(9)
        end
    end
    return nil
end

AddEventHandler('playerJoining', function()
    local id = source
    local license = getLicense(id)
    if not license then return end

    exports.oxmysql:execute('INSERT IGNORE INTO users (license, total_played) VALUES (?, 0)', {license}, function()
        if Config.Debug then
            NagePrint("debug", "Ensured DB row exists for %s", license)
        end
    end)

    players[id] = { license = license, minutes = 0, counting = true }

    CreateThread(function()
        while players[id] and players[id].counting do
            Wait(60000)
            if players[id] and players[id].counting then
                players[id].minutes = players[id].minutes + 1
                if not Config.Debug then 
                    NagePrint("debug", "Counting for %s: %d minute(s) (%s)", license, players[id].minutes, formatTime(players[id].minutes))
                end
            end
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local id = source
    local data = players[id]
    if data then
        data.counting = false
        exports.oxmysql:execute(
            'UPDATE users SET total_played = total_played + ? WHERE license = ?',
            { data.minutes, data.license },
            function()
                if Config.Debug then
                    NagePrint("debug", "Saved %d minute(s) for %s to database (%s)", data.minutes, data.license, formatTime(data.minutes))
                end
            end
        )
        players[id] = nil
    end
end)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for _, data in pairs(players) do
        data.counting = false
        exports.oxmysql:execute(
            'UPDATE users SET total_played = total_played + ? WHERE license = ?',
            { data.minutes, data.license },
            function()
                if Config.Debug then
                    NagePrint("debug", "Resource stopping: saved %d minute(s) for %s (%s)", data.minutes, data.license, formatTime(data.minutes))
                end
            end
        )
    end
end)
