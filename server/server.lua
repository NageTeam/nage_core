NAGE = exports['nage']:getSharedCode()
NAGE.PlayerCache = {}

local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
if not localeLoader then
    error("^4[Nage Core]^7 ^1[ERROR]^7: 'utils/locales.lua' could not be loaded in resource: " ..
    GetCurrentResourceName())
end
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

local requiredResourceName = "nage"
local localVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
local githubVersionUrl = "https://raw.githubusercontent.com/NageTeam/nage_core/main/version.txt"

if GetCurrentResourceName() ~= requiredResourceName then
    NagePrint("error", locale["resource_wrong_name"], requiredResourceName)
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

local function formatNumber(n)
    if not n then return "0" end
    local formatted = tostring(n)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return formatted
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    SetGameType('Nage Core')
    SetMapName('Los Santos')
end)

local function GetPlayerIdentifiersInfo(nPlayer)
    nPlayer = tonumber(nPlayer)
    if not nPlayer or nPlayer <= 0 then return nil end

    if NAGE.PlayerCache[nPlayer] then
        return NAGE.PlayerCache[nPlayer]
    end

    local rawIds = GetPlayerIdentifiers(nPlayer)
    if not rawIds or #rawIds == 0 then
        NagePrint("error", locale["no_identifiers_found"], NAGE.GetPlayerName(nPlayer) or "Unknown", nPlayer)
        return nil
    end

    local identifiers = {
        discord = nil,
        steam_name = NAGE.GetPlayerName(nPlayer) or "Unknown",
        steam_id = nil,
        license = nil,
        fivem_id = tostring(nPlayer)
    }

    for _, id in ipairs(rawIds) do
        if id:find("discord:") then
            identifiers.discord_id = id:gsub("discord:", "")
        elseif id:find("steam:") then
            identifiers.steam_id = id:gsub("steam:", "")
        elseif id:find("license:") then
            identifiers.license = id:gsub("license:", "")
        end
    end

    NAGE.PlayerCache[nPlayer] = identifiers

    return identifiers
end

local function updateLastConnected(nPlayer)
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)
    if not idInfo or not idInfo.license then return end

    exports.oxmysql:update('UPDATE users SET last_connected = NOW() WHERE license = ?', {
        idInfo.license
    }, function(rowsChanged)
        if Config.Debug and rowsChanged > 0 then
            NagePrint("info", locale["updated_last_connected"], idInfo.steam_name, os.date('%Y-%m-%d %H:%M:%S'))
        end
    end)
end

local function betterIdentifier(value)
    return (value and tostring(value) ~= "" ) and tostring(value) or "N/A"
end

local function AddPlayerToDatabase(nPlayer)
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)
    if not idInfo or not idInfo.license or idInfo.license == "" then
        NagePrint("error", locale["invalid_player_license"])
        DropPlayer(nPlayer, "[Nage Core] You do not have a valid license or identifier. Please contact the server administrator.")
        return
    end

    if not exports.oxmysql then
        NagePrint("error", locale["oxmysql_missing"])
        return
    end

    idInfo.discord_id = betterIdentifier(idInfo.discord_id)
    idInfo.steam_name = betterIdentifier(idInfo.steam_name)
    idInfo.steam_id = betterIdentifier(idInfo.steam_id)
    idInfo.license = betterIdentifier(idInfo.license)
    idInfo.fivem_id = betterIdentifier(idInfo.fivem_id)

    exports.oxmysql:query('SELECT * FROM users WHERE license = ?', { idInfo.license }, function(result)
        local lastConnected = os.date('%Y-%m-%d %H:%M:%S')
        local defaultRank = tostring((Config.Ranks and Config.Ranks.Normal) or 'user')

        if result and result[1] then
            local existing = result[1]

            if existing.steam_name ~= idInfo.steam_name then
                exports.oxmysql:update('UPDATE users SET `steam_name` = ? WHERE `license` = ?', {
                    idInfo.steam_name, idInfo.license
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        NagePrint("info", locale["updated_steam_name"], idInfo.steam_name, existing.steam_name or "N/A")
                    end
                end)
            elseif Config.Debug then
                NagePrint("debug", locale["player_exists"], existing.steam_name, existing.rank, existing.money)
            end
        else
            local insertQuery = [[
                INSERT INTO users (`discord`, `steam_name`, `steam_id`, `license`, `fivem_id`, `money`, `rank`, `last_connected`)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ]]
            local params = {
                idInfo.discord_id,
                idInfo.steam_name,
                idInfo.steam_id,
                idInfo.license,
                idInfo.fivem_id,
                tostring(Config.Money or 0),
                defaultRank,
                lastConnected
            }

            exports.oxmysql:insert(insertQuery, params, function(insertId)
                NagePrint("info", locale["new_player_added"], idInfo.steam_name, insertId or "unknown")
            end)
        end
    end)
end

local function checkVersionAndInitDB()
    PerformHttpRequest(githubVersionUrl, function(statusCode, response, _)
        if statusCode ~= 200 or not response then
            printBanner()
            NagePrint("error", locale["could_not_check_update"])
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
                `total_played` VARCHAR(50) DEFAULT NULL
            );
        ]], {}, function(result)
            if result == nil then
                print("^1[Nage Core]^7 ^1[ERROR]^7: Failed to create or check users table.")
                if Config.Debug then
                    NagePrint("debug", "Received nil result from DB query.")
                end
                return
            end

            exports.oxmysql:query('SELECT COUNT(*) as total FROM users', {}, function(result)
                local totalUsers = 0
                if result and result[1] then
                    totalUsers = result[1].total
                end

                printBanner()
                print("^2[Nage Core]^7 Nage Core is ^2Updated!^0")
                print("^2[Nage Core]^7 Version       : v" .. localVersion .. "^0")
                print("^2[Nage Core]^7 Total Users   : " .. formatNumber(totalUsers) .. "^0")
                print('^4[Nage Core]^7 ^5[INFO]^7: Database connection established\n')
            end)
        end)
    end)
end

CreateThread(checkVersionAndInitDB)

RegisterNetEvent('nage:checkFirstJoin')
AddEventHandler('nage:checkFirstJoin', function()
    local nPlayer = NAGE.PlayerID(source)
    local playerName = NAGE.GetPlayerName(nPlayer) or "Unknown"
    local idInfo = GetPlayerIdentifiersInfo(nPlayer)

    if idInfo and idInfo.license then
        exports.oxmysql:query('SELECT last_connected FROM users WHERE license = ?', { idInfo.license }, function(result)
            if result and result[1] and result[1].last_connected == nil then
                NagePrint("info", locale["first_time_join"], playerName)
                CreateThread(function()
                    Wait(2000)
                    updateLastConnected(nPlayer)
                end)
            else
                NagePrint("info", locale["welcome_back"], playerName)

                CreateThread(function()
                    Wait(10000)
                    updateLastConnected(nPlayer)
                    if Config.Debug then
                        NagePrint("debug", locale["last_connected_updated"], playerName)
                    end
                end)
            end
        end)
    end
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local nPlayer = NAGE.PlayerID(source)
    deferrals.defer()
    Wait(100)

    deferrals.update("[Nage Core] Checking your identifiers...")

    local idInfo = GetPlayerIdentifiersInfo(nPlayer)
    local identifiers = GetPlayerIdentifiers(nPlayer)
    local hasSteam = false

    for _, id in ipairs(identifiers) do
        if id:find("steam:") then
            hasSteam = true
            break
        end
    end

    if not hasSteam then
        deferrals.done("Steam Authentication Failed!\nMake sure Steam is running or restart FiveM. Find more information in console.\n")
        NagePrint("error", "Steam Auth Failed for player " .. playerName .. ". Check sv_licenseKey in server.cfg. Please reset or register a key on ^5https://steamcommunity.com/dev/apikey^7")
        return
    end

    if not idInfo or not idInfo.license then
        deferrals.done("[Nage Core] Missing valid license. Please restart FiveM or Steam.")
        NagePrint("error", locale["missing_valid_license"], playerName)
        return
    end

    if Config.Debug then
        NagePrint("debug", locale["player_identifiers"])
        for _, id in pairs(identifiers) do
            if not id:find("^ip:") then
                NagePrint("debug", "- %s", id)
            end
        end
    end

    if Config.DupeUser then
        for _, playerId in ipairs(GetPlayers()) do
            local pid = tonumber(playerId)
            if pid ~= source then
                local otherInfo = GetPlayerIdentifiersInfo(pid)
                if otherInfo and otherInfo.license == idInfo.license then
                    deferrals.done("[Nage Core] You are already connected to the server!")
                    NagePrint("warning", "Duplicate login attempt blocked for %s (%s)", playerName, idInfo.license)
                    return
                end
            end
        end
    end

    deferrals.update("[Nage Core] Searching your profile in the database...")

    AddPlayerToDatabase(nPlayer)
    Wait(500)

    exports.oxmysql:query('SELECT `rank` FROM users WHERE license = ?', { idInfo.license }, function(result)
        local rank = result and result[1] and result[1].rank or "user"

        CreateThread(function()
            deferrals.update("[Nage Core] Welcome " .. playerName .. "! Finalizing login...")
            Wait(500)
            deferrals.done()
            NagePrint("success", locale["player_connected_rank"], playerName, rank)
        end)
    end)
end)


AddEventHandler('playerDropped', function(reason)
    local nPlayer = NAGE.PlayerID(source)
    local idInfo = NAGE.PlayerCache[nPlayer]

    if idInfo then
        NagePrint("info", locale["player_disconnected"], idInfo.steam_name, reason or "Unknown")
    else
        local playerName = NAGE.GetPlayerName(nPlayer) or "Unknown"
        NagePrint("warn", "Player %s (src %s) disconnected without cached identifiers. Reason: %s", playerName, nPlayer, reason)
    end

    NAGE.PlayerCache[nPlayer] = nil
end)