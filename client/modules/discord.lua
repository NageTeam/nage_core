NAGE = exports['nage']:getSharedCode()

local queueNummer = 0

RegisterNetEvent('connectqueue:playerJoinQueue')
AddEventHandler('connectqueue:playerJoinQueue', function(count)
    queueNummer = count
end)

RegisterNetEvent('connectqueue:playerLeaveQueue')
AddEventHandler('connectqueue:playerLeaveQueue', function(count)
    queueNummer = count
end)

local function GetLiveZoneStatus()
    local ped = NAGE.PlayerPedID()
    local pos = NAGE.GetCoords(ped)

    for zoneName, zone in pairs(Config.Zones) do
        if IsPlayerInZone(zone, pos) then
            return "Inside zone: " .. zoneName
        end
    end

    return "Outside Zone"
end

Citizen.CreateThread(function()
    while true do
        local playerID = NAGE.PlayerID()
        local playerName = NAGE.GetPlayerName()
        local onlinePlayers = #GetActivePlayers()

        local zoneStatus = GetLiveZoneStatus()

        local presence = Config.DiscordActivity.presence
            :gsub("{player_id}", playerID)
            :gsub("{player_name}", playerName)
            :gsub("{online_players}", tostring(onlinePlayers))
            :gsub("{queue_number}", tostring(queueNummer))
            :gsub("{zone_status}", zoneStatus)

        SetDiscordAppId(Config.DiscordActivity.appId)
        SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
        SetDiscordRichPresenceAssetSmallText(Config.DiscordActivity.assetText)
        SetRichPresence(presence)

        for i, button in ipairs(Config.DiscordActivity.buttons) do
            SetDiscordRichPresenceAction(i - 1, button.label, button.url)
        end

        Citizen.Wait(Config.DiscordActivity.refresh)
    end
end)
