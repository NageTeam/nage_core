local NAGE = exports['nage']:getSharedCode()
local players = {}

local function formatPlaytime(totalMinutes)
    if not totalMinutes or totalMinutes <= 0 then return "0m" end

    local years = math.floor(totalMinutes / 525960)
    totalMinutes = totalMinutes % 525960

    local months = math.floor(totalMinutes / 43830)
    totalMinutes = totalMinutes % 43830

    local days = math.floor(totalMinutes / 1440)
    totalMinutes = totalMinutes % 1440

    local hours = math.floor(totalMinutes / 60)
    local minutes = totalMinutes % 60

    local parts = {}
    if years > 0 then table.insert(parts, years .. "y") end
    if months > 0 then table.insert(parts, months .. "mo") end
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end

    return table.concat(parts, " ")
end

local function getLicense(id)
    for _, v in ipairs(GetPlayerIdentifiers(id)) do
        if v:sub(1,7) == "license" then
            return v:sub(9)
        end
    end
    return nil
end

AddEventHandler('playerJoining', function()
    if not Config.PlayTime then return end

    local id = NAGE.PlayerID(source)
    local license = getLicense(id)
    if not license then return end

    exports.oxmysql:execute('INSERT IGNORE INTO users (license, total_played) VALUES (?, ?)', {license, 0}, function()
        exports.oxmysql:query('SELECT total_played FROM users WHERE license = ?', {license}, function(result)
            local totalMinutes = result and result[1] and tonumber(result[1].total_played) or 0

            players[id] = { license = license, minutes = totalMinutes, counting = true }

            if Config.Debug and Config.PlayTime then
                NagePrint("debug", "Loaded %d minutes for %s (%s)", totalMinutes, license, formatPlaytime(totalMinutes))
            end

            CreateThread(function()
                while players[id] and players[id].counting do
                    Wait(60000)
                    if players[id] and players[id].counting then
                        players[id].minutes = players[id].minutes + 1
                        if Config.Debug and Config.PlayTime then
                            NagePrint("debug", "Counting for %s: %d minute(s) (%s)", license, players[id].minutes, formatPlaytime(players[id].minutes))
                        end
                    end
                end
            end)
        end)
    end)
end)

AddEventHandler('playerDropped', function()
    if not Config.PlayTime then return end

    local id = NAGE.PlayerID(source)
    local data = players[id]
    if data then
        data.counting = false
        exports.oxmysql:execute(
            'UPDATE users SET total_played = ? WHERE license = ?',
            { data.minutes, data.license },
            function()
                if Config.Debug and Config.PlayTime then
                    NagePrint("debug", "Saved %d minutes (%s) for %s", data.minutes, formatPlaytime(data.minutes), data.license)
                end
            end
        )
        players[id] = nil
    end
end)

AddEventHandler('onResourceStop', function(resName)
    if not Config.PlayTime then return end
    if resName ~= GetCurrentResourceName() then return end

    for _, data in pairs(players) do
        data.counting = false
        exports.oxmysql:execute(
            'UPDATE users SET total_played = ? WHERE license = ?',
            { data.minutes, data.license },
            function()
                if Config.Debug and Config.PlayTime then
                    NagePrint("debug", "Resource stopping: saved %d minutes (%s) for %s", data.minutes, formatPlaytime(data.minutes), data.license)
                end
            end
        )
    end
end)
