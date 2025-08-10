NAGE = exports['nage']:getSharedCode()
NAGE.ServerCallbacks = {}

local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
if not localeLoader then
    error("^4[Nage Core]^7 ^1[ERROR]^7: 'utils/locales.lua' could not be loaded in resource: " ..
    GetCurrentResourceName())
end
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

local requiredResourceName = "nage"
local localVersion = "1.0.2"
local developer = "Nage Team"
local githubVersionUrl = "https://raw.githubusercontent.com/NageTeam/nage_core/main/version.txt"

local playerJoinTimes = {}

if GetCurrentResourceName() ~= requiredResourceName then
    print(("^1[Nage Core] - [ERROR]^7 " .. locale["resource_wrong_name"]):format(requiredResourceName))
    StopResource(GetCurrentResourceName())
    return
end

local function printBanner()
    print([[^5
 _   _                     _____
| \ | |                   / ____|
|  \| | __ _  __ _  ___  | |     ___  _ __ ___
| . ` |/ _` |/ _` |/ _ \ | |    / _ \| '__/ _ \
| |\  | (_| | (_| |  __/ | |___| (_) | | |  __/
|_| \_|\__,_|\__, |\___|  \_____\___/|_|  \___|
              __/ |
             |___/
    ^0]])
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetGameType('Nage Core')
    SetMapName('Los Santos')
end)

local function formatPlayTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    local parts = {}
    table.insert(parts, days .. (days == 1 and " day" or " days"))
    table.insert(parts, hours .. (hours == 1 and " hour" or " hours"))
    table.insert(parts, minutes .. (minutes == 1 and " minute" or " minutes"))

    return table.concat(parts, ", ")
end

local function GetPlayerIdentifiersInfo(nPlayer)
    nPlayer = tonumber(nPlayer)
    if not nPlayer or nPlayer <= 0 then return nil end

    local rawIds = GetPlayerIdentifiers(nPlayer)
    if not rawIds or #rawIds == 0 then
        print(("^1[Nage Core]^7 [ERROR]: " .. locale["no_identifiers_found"]):format(GetPlayerName(nPlayer) or "Unknown", nPlayer))
        return nil
    end

    local identifiers = {
        discord = nil,
        steam_name = GetPlayerName(nPlayer) or "Unknown",
        steam_id = nil,
        license = nil,
        fivem_id = tostring(nPlayer)
    }

    for _, id in ipairs(rawIds) do
        if id:find("discord:") then
            identifiers.discord = id:gsub("discord:", "")
        elseif id:find("steam:") then
            identifiers.steam_id = id:gsub("steam:", "")
        elseif id:find("license:") then
            identifiers.license = id:gsub("license:", "")
        end
    end

    return identifiers
end

local function updateLastConnected(nPlayer)
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)
    if not idInfo or not idInfo.license then return end

    if not exports.oxmysql then
        if Config.Debug then
            print("^1[Nage Core]^7 ^1[ERROR]^7: oxmysql export not available.")
        end
        return
    end

    exports.oxmysql:update('UPDATE users SET last_connected = NOW() WHERE license = ?', { idInfo.license }, function(rowsChanged)
        if Config.Debug then
            if rowsChanged and rowsChanged > 0 then
                print("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["updated_last_connected"]:format(idInfo.steam_name, os.date('%Y-%m-%d %H:%M:%S')))
            else
                print("^4[Nage Core]^7 ^5[INFO]^7: No last_connected update needed for " .. idInfo.steam_name)
            end
        end
    end)
end

local function AddPlayerToDatabase(nPlayer)
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)
    if not idInfo or not idInfo.license or idInfo.license == "" then
        print("^1[Nage Core]^7 ^1[ERROR]^7: " .. locale["invalid_player_license"])
        DropPlayer(nPlayer, "[Nage Core] You do not have a valid license or identifier. Please contact the server administrator.")
        return
    end

    if not exports.oxmysql then
        print("^1[Nage Core]^7 ^1[ERROR]^7: " .. locale["oxmysql_missing"])
        return
    end

    exports.oxmysql:query('SELECT * FROM users WHERE license = ?', { idInfo.license }, function(result)
        if result and result[1] then
            local existing = result[1]
            if existing.steam_name ~= idInfo.steam_name then
                exports.oxmysql:update('UPDATE users SET steam_name = ? WHERE license = ?', { idInfo.steam_name, idInfo.license }, function(rowsChanged)
                    if Config.Debug then
                        if rowsChanged and rowsChanged > 0 then
                            print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["updated_steam_name"]):format(idInfo.steam_name, existing.steam_name))
                        else
                            print(("^4[Nage Core]^7 ^5[INFO]^7: No steam_name update needed for %s"):format(idInfo.steam_name))
                        end
                    end
                end)
            elseif Config.Debug then
                print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["player_exists"]):format(existing.steam_name, existing.rank or "unknown", existing.money or 0))
            end
        else
            exports.oxmysql:insert('INSERT INTO users (discord, steam_name, steam_id, license, fivem_id, money, `rank`, last_connected) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                idInfo.discord,
                idInfo.steam_name,
                idInfo.steam_id,
                idInfo.license,
                idInfo.fivem_id,
                tonumber(Config.Money) or 0,
                'user',
                nil
            }, function(insertId)
                if insertId then
                    print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["new_player_added"]):format(idInfo.steam_name, insertId))
                elseif Config.Debug then
                    print(("^4[Nage Core]^7 ^1[ERROR]^7: Failed to insert player %s into database"):format(idInfo.steam_name))
                end
            end)
        end
    end)
end

local function checkVersionAndInitDB()
    PerformHttpRequest(githubVersionUrl, function(statusCode, response, _)
        if statusCode ~= 200 or not response then
            printBanner()
            print("^4[Nage Core]^7 " .. locale["could_not_check_update"])
            return
        end

        local remoteVersion = response:match("^%s*(.-)%s*$")
        if remoteVersion ~= localVersion then
            printBanner()
            print("^1[Nage Core]^7 Nage Core is ^1Outdated!^0")
            print("^1[Nage Core]^7 Your version    : v" .. localVersion .. "^0")
            print("^1[Nage Core]^7 Latest version  : v" .. remoteVersion .. "^0")
            return
        end

        local startTime = os.clock()
        
        exports.oxmysql:query([[
            CREATE TABLE IF NOT EXISTS `users` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `discord` VARCHAR(50) DEFAULT NULL,
                `steam_name` VARCHAR(100) DEFAULT NULL,
                `steam_id` VARCHAR(50) DEFAULT NULL,
                `license` VARCHAR(50) NOT NULL UNIQUE,
                `fivem_id` VARCHAR(50) DEFAULT NULL,
                `money` INT DEFAULT 0,
                `rank` VARCHAR(50) DEFAULT 'user',
                `last_connected` VARCHAR(50) DEFAULT 'Never',
                `total_played` INT DEFAULT 0
            );
            ]], {}, function(result)
            if result == nil then
                print("^1[Nage Core]^7 ^1[ERROR]^7: Failed to create or check users table.")
                if Config.Debug then
                    print("^1[Nage Core]^7 ^1[ERROR]^7: Received nil result from DB query.")
                end
                return
            end

            local loadTime = string.format("%.2f", (os.clock() - startTime) * 1000)
            printBanner()
            print("^2[Nage Core]^7 Nage Core is ^2Updated!^0")
            print("^2[Nage Core]^7 Developer  : " .. developer .. "^0")
            print("^2[Nage Core]^7 Version    : v" .. localVersion .. "^0")
            print("^2[Nage Core]^7 Load Time  : " .. loadTime .. "ms^0")
            print('^4[Nage Core]^7 ^5[INFO]^7: Database connection established\n')
        end)
    end)
end

CreateThread(checkVersionAndInitDB)

RegisterNetEvent('nage:checkFirstJoin')
AddEventHandler('nage:checkFirstJoin', function()
    local nPlayer = NAGE.PlayerID(source)
    local playerName = GetPlayerName(nPlayer) or "Unknown"
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)

    if not idInfo or not idInfo.license then
        if Config.Debug then
            print("^1[Nage Core]^7 ^1[ERROR]^7: Missing license on first join check for player " .. playerName)
        end
        return
    end

    exports.oxmysql:query('SELECT last_connected FROM users WHERE license = ?', { idInfo.license }, function(result)
        if result and result[1] and (result[1].last_connected == nil or result[1].last_connected == "") then
            print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["first_time_join"]):format(playerName))
            CreateThread(function()
                Wait(2000)
                updateLastConnected(nPlayer)
            end)
        else
            print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["welcome_back"]):format(playerName))
            CreateThread(function()
                Wait(10000)
                updateLastConnected(nPlayer)
                if Config.Debug then
                    print(("^4[Nage Core]^7 ^5[INFO]^7: " .. locale["last_connected_updated"]):format(playerName))
                end
            end)
        end
    end)
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local nPlayer = NAGE.PlayerID(source)
    deferrals.defer()
    Wait(100)

    deferrals.update("[Nage Core] Checking your identifiers...")

    local idInfo = GetPlayerIdentifiersInfo(nPlayer)

    if not idInfo or not idInfo.license then
        deferrals.done("[Nage Core] Missing valid license. Please restart FiveM or Steam.")
        print(('^1[Nage Core]^7 ^1[JOIN ERROR]^7: "' .. locale["missing_valid_license"] .. '"'):format(playerName))
        return
    end

    if Config.Debug then
        print(locale["player_identifiers"])
        for _, id in pairs(GetPlayerIdentifiers(nPlayer)) do
            if not id:find("^ip:") then
                print("^4[Nage Core]^7  → " .. id)
            end
        end
    end

    deferrals.update("[Nage Core] Searching your profile in the database...")

    AddPlayerToDatabase(nPlayer)

    exports.oxmysql:query('SELECT `rank` FROM users WHERE license = ?', { idInfo.license }, function(result)
        local rank = "user"
        if result and result[1] and result[1].rank then
            rank = result[1].rank
        end

        CreateThread(function()
            if Config.Ranks and Config.Ranks.Admins and Config.Ranks.Admins[rank] then
                deferrals.update('[Nage Core] 👑 Welcome back, your majesty. Please try not to "accidentally" ban everyone & break everything again. 😏')
                Wait(2500)
            else
                deferrals.update("[Nage Core] Welcome " .. playerName .. "! Finalizing login...")
            end

            Wait(500)
            deferrals.done()
            print(("^4[Nage Core]^7 ^2[CONNECT]^7: " .. locale["player_connected_rank"]):format(playerName, rank))
        end)
    end)
end)

AddEventHandler('playerSpawned', function()
    local src = source
    playerJoinTimes[src] = os.time()
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerName = GetPlayerName(src) or "Unknown"
    local joinTime = playerJoinTimes[src]

    if joinTime then
        local playedSeconds = os.time() - joinTime
        local idInfo = GetPlayerIdentifiersInfo(src)

        if idInfo and idInfo.license then
            exports.oxmysql:query('SELECT total_played FROM users WHERE license = ?', { idInfo.license }, function(result)
                local totalPlayed = 0
                if result and result[1] and result[1].total_played then
                    totalPlayed = tonumber(result[1].total_played) or 0
                end
                totalPlayed = totalPlayed + playedSeconds

                exports.oxmysql:execute('UPDATE users SET total_played = ? WHERE license = ?', { totalPlayed, idInfo.license }, function(affectedRows)
                    if Config.Debug and affectedRows and affectedRows > 0 then
                        print(("^4[Nage Core]^7 ^5[INFO]^7: Updated total played time for %s: %s"):format(playerName, formatPlayTime(totalPlayed)))
                    end
                end)
            end)
        end
        playerJoinTimes[src] = nil
    end

    print(("^4[Nage Core]^7 ^1[LEFT]^7: " .. locale["player_disconnected"]):format(playerName, reason or "Unknown"))
end)

NAGE.ServerCallback("nage:checkAdminAccess", function(source, cb)
    if not source or source == 0 then
        cb(false)
        return
    end

    local license
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if id:find("license:") then
            license = id:sub(9)
            break
        end
    end

    if not license then
        cb(false)
        return
    end

    exports.oxmysql:query("SELECT `rank` FROM users WHERE license = ?", { license }, function(result)
        if not result or not result[1] or not result[1].rank then
            cb(false)
            return
        end

        local userGroup = result[1].rank

        local isAdmin = false
        if Config.Ranks and Config.Ranks.Admins then
            for _, rank in pairs(Config.Ranks.Admins) do
                if rank:lower() == userGroup:lower() then
                    isAdmin = true
                    break
                end
            end
        end

        cb(isAdmin)
    end)
end)

RegisterNetEvent("nage:bringPlayer", function(targetId)
    local nPlayer = NAGE.PlayerID(source)
    local ped = GetPlayerPed(nPlayer)
    if not ped then return end
    local coords = GetEntityCoords(ped)
    TriggerClientEvent("nage:teleportToCoords", targetId, coords)
end)

RegisterNetEvent("nage:gotoPlayer")
AddEventHandler("nage:gotoPlayer", function(targetId)
    local nPlayer = NAGE.PlayerID(source)

    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('nage_notify:notify', nPlayer, {
            title = locale["invalid_player_id"],
            type = 'error'
        })
        return
    end

    local targetPed = GetPlayerPed(targetId)
    if not targetPed then
        TriggerClientEvent('nage_notify:notify', nPlayer, {
            title = locale["invalid_player_id"],
            type = 'error'
        })
        return
    end

    local targetCoords = GetEntityCoords(targetPed)

    TriggerClientEvent('nage:teleportPlayer', nPlayer, targetCoords.x, targetCoords.y, targetCoords.z + 1.0)
end)
